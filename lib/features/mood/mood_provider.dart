import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// My streak row in the active group.
final myStreakProvider = FutureProvider<StreakInfo>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (gid == null || uid == null) return StreakInfo.empty();
  final row = await ref
      .watch(supabaseProvider)
      .from('streaks')
      .select()
      .eq('group_id', gid)
      .eq('user_id', uid)
      .maybeSingle();
  return row == null ? StreakInfo.empty() : StreakInfo.fromJson(row);
});

/// My moods over the past 30 days (aura + quick stats).
final my30DayMoodsProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (gid == null || uid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('moods')
      .select()
      .eq('group_id', gid)
      .eq('user_id', uid)
      .gte('logged_at',
          DateTime.now().subtract(const Duration(days: 30)).toUtc().toIso8601String())
      .order('logged_at');
  return (rows as List)
      .map((r) => MoodEntry.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// My moods for the calendar (last ~120 days).
final myCalendarMoodsProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  final uid = ref.watch(currentUserIdProvider);
  if (gid == null || uid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('moods')
      .select()
      .eq('group_id', gid)
      .eq('user_id', uid)
      .gte(
          'logged_at',
          DateTime.now()
              .subtract(const Duration(days: 120))
              .toUtc()
              .toIso8601String())
      .order('logged_at');
  return (rows as List)
      .map((r) => MoodEntry.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class MoodResult {
  final Quote? quote;
  final Song? song;
  final StreakInfo streak;
  MoodResult({this.quote, this.song, required this.streak});
}

class MoodController {
  final Ref ref;
  MoodController(this.ref);

  /// Logs the mood (streak handled server-side) and fetches matching content.
  Future<MoodResult> logMood(Mood mood) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final sb = ref.read(supabaseProvider);

    final streakRow = await sb.rpc('log_mood',
        params: {'p_group': gid, 'p_mood': mood.key});
    final streak =
        StreakInfo.fromJson((streakRow as Map).cast<String, dynamic>());

    final content = await sb.rpc('pick_mood_content',
        params: {'p_group': gid, 'p_mood': mood.key});
    Quote? quote;
    Song? song;
    if (content is List && content.isNotEmpty) {
      final row = (content.first as Map).cast<String, dynamic>();
      if (row['quote_text'] != null) {
        quote = Quote(
            id: row['quote_id'] ?? '',
            mood: mood,
            text: row['quote_text']);
      }
      if (row['song_url'] != null) {
        song = Song(
          id: row['song_id'] ?? '',
          mood: mood,
          title: row['song_title'] ?? 'A song for you',
          artist: row['song_artist'],
          url: row['song_url'],
          platform: row['song_platform'] ?? 'youtube',
        );
      }
    }

    ref.invalidate(myStreakProvider);
    ref.invalidate(my30DayMoodsProvider);
    ref.invalidate(myCalendarMoodsProvider);
    return MoodResult(quote: quote, song: song, streak: streak);
  }
}

final moodControllerProvider = Provider((ref) => MoodController(ref));
