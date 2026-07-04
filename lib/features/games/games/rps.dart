import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Best-of-5 Rock Paper Scissors.
/// state = { "picks": {uid: "rock|paper|scissors"}, "round": n,
///           "wins": {uid: n} }
class RpsBoard extends ConsumerWidget with GameBoardHelpers {
  final GameSession session;
  final List<GamePlayer> players;
  @override
  final List<GroupMember> members;

  const RpsBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  static const _moves = {
    'rock': '🪨',
    'paper': '📄',
    'scissors': '✂️',
  };

  int _beats(String a, String b) {
    if (a == b) return 0;
    const winMap = {'rock': 'scissors', 'paper': 'rock', 'scissors': 'paper'};
    return winMap[a] == b ? 1 : -1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(currentUserIdProvider)!;
    final picks = (session.state['picks'] as Map?)?.cast<String, dynamic>() ?? {};
    final wins = (session.state['wins'] as Map?)?.cast<String, dynamic>() ?? {};
    final round = session.state['round'] ?? 1;
    final iPicked = picks.containsKey(myId);
    final bothPicked = players.every((p) => picks.containsKey(p.userId));

    Future<void> pick(String move) async {
      if (iPicked) return;
      final newPicks = {...picks, myId: move};
      final everyone = players.every((p) => newPicks.containsKey(p.userId));

      Map<String, dynamic> newState;
      bool finish = false;
      String? winner;
      Map<String, int>? scores;

      if (everyone && players.length == 2) {
        final a = players[0].userId, b = players[1].userId;
        final result = _beats(newPicks[a], newPicks[b]);
        final newWins = {...wins};
        if (result == 1) {
          newWins[a] = (newWins[a] ?? 0) + 1;
        } else if (result == -1) {
          newWins[b] = (newWins[b] ?? 0) + 1;
        }
        final aWins = (newWins[a] ?? 0) as int;
        final bWins = (newWins[b] ?? 0) as int;
        if (aWins >= 3 || bWins >= 3) {
          finish = true;
          winner = aWins >= 3 ? a : b;
          scores = {a: aWins, b: bWins};
          newState = {'picks': {}, 'wins': newWins, 'round': round, 'reveal': newPicks};
        } else {
          // next round: clear picks, keep wins
          newState = {'picks': {}, 'wins': newWins, 'round': round + 1, 'reveal': newPicks};
        }
      } else {
        newState = {'picks': newPicks, 'wins': wins, 'round': round};
      }

      await ref.read(gameControllerProvider).submitMove(
            session.id,
            {'move': move},
            newState: newState,
            finish: finish,
            winner: winner,
            scores: scores,
          );
    }

    final reveal = (session.state['reveal'] as Map?)?.cast<String, dynamic>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Text('Round $round · first to 3',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        // scoreboard
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final p in players)
              Column(
                children: [
                  Text(roleOf(p.userId)),
                  Text('${wins[p.userId] ?? 0}',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (reveal != null && reveal.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final p in players)
                    Column(children: [
                      Text(roleOf(p.userId),
                          style: const TextStyle(fontSize: 12)),
                      Text(_moves[reveal[p.userId]] ?? '❓',
                          style: const TextStyle(fontSize: 40)),
                    ]),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (iPicked && !bothPicked)
          const Center(child: Text('Waiting for the other player… 🕒'))
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final entry in _moves.entries)
                GestureDetector(
                  onTap: iPicked ? null : () => pick(entry.key),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: iPicked ? 0.03 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(entry.value,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
