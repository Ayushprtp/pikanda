import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// The group's pet (one per group for now — first row wins).
final petProvider = FutureProvider<Pet?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('pets')
      .select()
      .eq('group_id', gid)
      .order('created_at')
      .limit(1)
      .maybeSingle();
  return row == null ? null : Pet.fromJson(row);
});

/// Realtime: refresh pet on any change (any member's care action).
final petRealtimeProvider = Provider<void>((ref) {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return;
  final channel = ref
      .watch(supabaseProvider)
      .channel('pet:$gid')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'pets',
        filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, column: 'group_id', value: gid),
        callback: (_) => ref.invalidate(petProvider),
      )
      .subscribe();
  ref.onDispose(() => channel.unsubscribe());
});

/// Recent care actions (who did what).
final petCareLogProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, petId) async {
  final rows = await ref
      .watch(supabaseProvider)
      .from('pet_care_actions')
      .select('*, users(display_name, username)')
      .eq('pet_id', petId)
      .order('created_at', ascending: false)
      .limit(20);
  return (rows as List).map((r) => (r as Map).cast<String, dynamic>()).toList();
});

class PetController {
  final Ref ref;
  PetController(this.ref);

  Future<Pet> adopt(String name, PetSpecies species) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    final row = await ref.read(supabaseProvider).from('pets').insert({
      'group_id': gid,
      'name': name,
      'species': species.key,
      'adopted_by': uid,
    }).select().single();
    ref.invalidate(petProvider);
    return Pet.fromJson(row);
  }

  /// Returns null on success, or an error code ('COOLDOWN' etc).
  Future<String?> care(String petId, String action) async {
    try {
      await ref
          .read(supabaseProvider)
          .rpc('care_for_pet', params: {'p_pet': petId, 'p_action': action});
      ref.invalidate(petProvider);
      ref.invalidate(petCareLogProvider(petId));
      return null;
    } on PostgrestException catch (e) {
      return e.message.contains('COOLDOWN')
          ? 'COOLDOWN'
          : e.message.contains('NOT_A_MEMBER')
              ? 'NOT_A_MEMBER'
              : e.message;
    }
  }
}

final petControllerProvider = Provider((ref) => PetController(ref));
