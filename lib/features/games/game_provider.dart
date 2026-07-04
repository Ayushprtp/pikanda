import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// Open/active games in the group (lobby + active).
final openGamesProvider = FutureProvider<List<GameSession>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('game_sessions')
      .select()
      .eq('group_id', gid)
      .inFilter('status', ['lobby', 'active'])
      .order('created_at', ascending: false);
  return (rows as List)
      .map((r) => GameSession.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// Realtime list of open games.
final gamesRealtimeProvider = Provider<void>((ref) {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return;
  final channel = ref
      .watch(supabaseProvider)
      .channel('games:$gid')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'game_sessions',
        filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, column: 'group_id', value: gid),
        callback: (_) => ref.invalidate(openGamesProvider),
      )
      .subscribe();
  ref.onDispose(() => channel.unsubscribe());
});

/// Single session (realtime-refreshed inside the game screen).
final gameSessionProvider =
    FutureProvider.family<GameSession?, String>((ref, id) async {
  final row = await ref
      .watch(supabaseProvider)
      .from('game_sessions')
      .select()
      .eq('id', id)
      .maybeSingle();
  return row == null ? null : GameSession.fromJson(row);
});

final gamePlayersProvider =
    FutureProvider.family<List<GamePlayer>, String>((ref, id) async {
  final rows = await ref
      .watch(supabaseProvider)
      .from('game_players')
      .select()
      .eq('session_id', id)
      .order('player_index');
  return (rows as List)
      .map((r) => GamePlayer.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// Group leaderboard (wins).
final leaderboardProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('game_leaderboard')
      .select()
      .eq('group_id', gid)
      .order('wins', ascending: false);
  return (rows as List).map((r) => (r as Map).cast<String, dynamic>()).toList();
});

class GameController {
  final Ref ref;
  GameController(this.ref);

  SupabaseClient get _sb => ref.read(supabaseProvider);

  Future<GameSession> create(GameType type, {int? maxPlayers}) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final row = await _sb.rpc('create_game', params: {
      'p_group': gid,
      'p_type': type.key,
      'p_max_players': maxPlayers ?? type.defaultMaxPlayers,
    });
    ref.invalidate(openGamesProvider);
    return GameSession.fromJson((row as Map).cast<String, dynamic>());
  }

  Future<void> join(String sessionId) async {
    await _sb.rpc('join_game', params: {'p_session': sessionId});
    ref.invalidate(gameSessionProvider(sessionId));
    ref.invalidate(gamePlayersProvider(sessionId));
  }

  Future<void> start(String sessionId) async {
    await _sb.rpc('start_game', params: {'p_session': sessionId});
    ref.invalidate(gameSessionProvider(sessionId));
  }

  Future<void> submitMove(
    String sessionId,
    Map<String, dynamic> move, {
    Map<String, dynamic>? newState,
    String? nextTurn,
    bool finish = false,
    String? winner,
    Map<String, int>? scores,
  }) async {
    await _sb.rpc('submit_move', params: {
      'p_session': sessionId,
      'p_move': move,
      'p_new_state': newState,
      'p_next_turn': nextTurn,
      'p_finish': finish,
      'p_winner': winner,
      'p_scores': scores,
    });
    ref.invalidate(gameSessionProvider(sessionId));
    ref.invalidate(gamePlayersProvider(sessionId));
  }
}

final gameControllerProvider = Provider((ref) => GameController(ref));
