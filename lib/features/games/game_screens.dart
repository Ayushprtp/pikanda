
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'game_provider.dart';
import 'games/tictactoe.dart';
import 'games/rps.dart';
import 'games/memory_match.dart';
import 'games/tap_race.dart';
import 'games/word_guess.dart';
import 'games/connect4.dart';
import 'games/reaction_duel.dart';

/// Hosts a single realtime game session: lobby → active board → result.
class GameSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const GameSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<GameSessionScreen> createState() => _GameSessionScreenState();
}

class _GameSessionScreenState extends ConsumerState<GameSessionScreen> {
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    final sb = ref.read(supabaseProvider);
    _channel = sb
        .channel('game_session:${widget.sessionId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_sessions',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: widget.sessionId),
          callback: (_) {
            ref.invalidate(gameSessionProvider(widget.sessionId));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_players',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'session_id',
              value: widget.sessionId),
          callback: (_) {
            ref.invalidate(gamePlayersProvider(widget.sessionId));
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider(widget.sessionId));
    final players = ref.watch(gamePlayersProvider(widget.sessionId)).valueOrNull ?? [];
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(session.valueOrNull?.gameType.label ?? 'Game'),
      ),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (s) {
          if (s == null) {
            return const EmptyState(emoji: '👻', message: 'Game not found');
          }
          final iAmIn = players.any((p) => p.userId == myId);

          if (s.status == 'lobby') {
            return _Lobby(
                session: s,
                players: players,
                members: members,
                myId: myId,
                iAmIn: iAmIn);
          }

          final board = switch (s.gameType) {
            GameType.tictactoe =>
              TicTacToeBoard(session: s, players: players, members: members),
            GameType.rps =>
              RpsBoard(session: s, players: players, members: members),
            GameType.memoryMatch =>
              MemoryMatchBoard(session: s, players: players, members: members),
            GameType.tapRace =>
              TapRaceBoard(session: s, players: players, members: members),
            GameType.wordGuess =>
              WordGuessBoard(session: s, players: players, members: members),
            GameType.connect4 =>
              Connect4Board(session: s, players: players, members: members),
            GameType.reactionDuel =>
              ReactionDuelBoard(session: s, players: players, members: members),
          };

          if (s.status == 'finished') {
            return _ResultView(
                session: s, players: players, members: members, board: board);
          }
          return board;
        },
      ),
    );
  }
}

class _Lobby extends ConsumerWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;
  final String? myId;
  final bool iAmIn;

  const _Lobby({
    required this.session,
    required this.players,
    required this.members,
    required this.myId,
    required this.iAmIn,
  });

  String roleOf(String uid) {
    for (final m in members) {
      if (m.userId == uid) return m.roleName;
    }
    return 'player';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHost = session.createdBy == myId;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
            child: Text(session.gameType.emoji,
                style: const TextStyle(fontSize: 72))),
        const SizedBox(height: 8),
        Center(
          child: Text('${session.gameType.label} lobby',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        Center(
          child: Text('${players.length}/${session.maxPlayers} players',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55))),
        ),
        const SizedBox(height: 16),
        for (final p in players)
          SectionCard(
            child: Row(
              children: [
                MemberAvatar(
                    member: members.firstWhere(
                        (m) => m.userId == p.userId,
                        orElse: () => members.isNotEmpty
                            ? members.first
                            : GroupMember(
                                id: '',
                                groupId: '',
                                userId: p.userId,
                                roleName: 'player',
                                isAdmin: false,
                                joinedAt: DateTime.now())),
                    radius: 16),
                const SizedBox(width: 12),
                Text(roleOf(p.userId),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (p.userId == session.createdBy)
                  const Chip(label: Text('Host')),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (!iAmIn)
          FilledButton.icon(
            onPressed: () async {
              try {
                await ref.read(gameControllerProvider).join(session.id);
              } catch (e) {
                if (context.mounted) showSnack(context, 'Failed: $e');
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Join game'),
          ),
        if (isHost && players.length >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton.icon(
              onPressed: () async {
                try {
                  await ref.read(gameControllerProvider).start(session.id);
                } catch (e) {
                  if (context.mounted) showSnack(context, 'Failed: $e');
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start now'),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            session.maxPlayers > 2
                ? 'Game starts when the host presses Start.'
                : 'Game starts automatically when full.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends ConsumerWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;
  final Widget board;

  const _ResultView({
    required this.session,
    required this.players,
    required this.members,
    required this.board,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String roleOf(String? uid) {
      for (final m in members) {
        if (m.userId == uid) return m.roleName;
      }
      return 'nobody';
    }

    final winner = session.winnerId;
    final myId = ref.watch(currentUserIdProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
          child: Column(
            children: [
              Text(winner == null ? '🤝' : (winner == myId ? '🎉' : '🏁'),
                  style: const TextStyle(fontSize: 56)),
              Text(
                  winner == null
                      ? 'It\'s a draw!'
                      : winner == myId
                          ? 'You won!'
                          : '${roleOf(winner)} won!',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        if (players.any((p) => p.score != 0))
          SectionCard(
            child: Column(
              children: [
                for (final p in players
                  ..sort((a, b) => b.score.compareTo(a.score)))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text(roleOf(p.userId))),
                        Text('${p.score}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => context.go('/games'),
          icon: const Icon(Icons.replay),
          label: const Text('Back to games'),
        ),
      ],
    );
  }
}
