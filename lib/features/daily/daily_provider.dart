import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

String _todayIso() {
  final now = DateTime.now().toUtc();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

final todayThoughtProvider = FutureProvider<ThoughtOfDay?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('thought_of_day')
      .select()
      .eq('group_id', gid)
      .eq('date', _todayIso())
      .maybeSingle();
  return row == null ? null : ThoughtOfDay.fromJson(row);
});

final todayDareProvider = FutureProvider<Dare?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('dares')
      .select('*, dare_completions(user_id)')
      .eq('group_id', gid)
      .eq('date', _todayIso())
      .maybeSingle();
  return row == null ? null : Dare.fromJson(row);
});

final activeScheduledMessagesProvider =
    FutureProvider<List<ScheduledMessage>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('scheduled_messages')
      .select()
      .eq('group_id', gid)
      .order('send_time');
  return (rows as List)
      .map((r) => ScheduledMessage.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class DailyController {
  final Ref ref;
  DailyController(this.ref);

  Future<void> completeDare(String dareId) async {
    final uid = ref.read(currentUserIdProvider)!;
    await ref
        .read(supabaseProvider)
        .from('dare_completions')
        .insert({'dare_id': dareId, 'user_id': uid});
    ref.invalidate(todayDareProvider);
  }

  Future<void> setThought(String text) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    await ref.read(supabaseProvider).from('thought_of_day').upsert({
      'group_id': gid,
      'created_by': uid,
      'thought': text,
      'date': _todayIso(),
    }, onConflict: 'group_id,date');
    ref.invalidate(todayThoughtProvider);
  }

  Future<void> setDare(String text) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    await ref.read(supabaseProvider).from('dares').upsert({
      'group_id': gid,
      'created_by': uid,
      'dare_text': text,
      'date': _todayIso(),
    }, onConflict: 'group_id,date');
    ref.invalidate(todayDareProvider);
  }

  Future<void> addScheduledMessage(String message, String time) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    await ref.read(supabaseProvider).from('scheduled_messages').insert({
      'group_id': gid,
      'created_by': uid,
      'message': message,
      'send_time': time,
    });
    ref.invalidate(activeScheduledMessagesProvider);
  }

  Future<void> deleteScheduledMessage(String id) async {
    await ref.read(supabaseProvider).from('scheduled_messages').delete().eq('id', id);
    ref.invalidate(activeScheduledMessagesProvider);
  }
}

final dailyControllerProvider = Provider((ref) => DailyController(ref));
