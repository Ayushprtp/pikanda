import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// state = { "board": [9 cells of "", "X", "O"] }
/// players[0] = X, players[1] = O
class TicTacToeBoard extends ConsumerWidget with GameBoardHelpers {
  final GameSession session;
  final List<GamePlayer> players;
  @override
  final List<GroupMember> members;

  const TicTacToeBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  List<String> get _board {
    final raw = session.state['board'];
    if (raw is List && raw.length == 9) {
      return raw.map((e) => e.toString()).toList();
    }
    return List.filled(9, '');
  }

  String _symbolFor(String uid) {
    final idx = players.indexWhere((p) => p.userId == uid);
    return idx == 0 ? 'X' : 'O';
  }

  String? _winner(List<String> b) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final l in lines) {
      if (b[l[0]].isNotEmpty && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) {
        return b[l[0]];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(currentUserIdProvider);
    final myTurn = session.currentTurn == myId;
    final board = _board;
    final mySymbol = myId == null ? '' : _symbolFor(myId);

    Future<void> tap(int i) async {
      if (!myTurn || board[i].isNotEmpty) return;
      final next = [...board];
      next[i] = mySymbol;
      final win = _winner(next);
      final full = !next.contains('');
      final finish = win != null || full;

      // Next turn = the other player.
      final otherId = players.firstWhere((p) => p.userId != myId,
          orElse: () => players.first).userId;

      await ref.read(gameControllerProvider).submitMove(
            session.id,
            {'cell': i, 'symbol': mySymbol},
            newState: {'board': next},
            nextTurn: finish ? null : otherId,
            finish: finish,
            winner: win != null ? myId : null,
            scores: win != null ? {myId!: 1} : null,
          );
    }

    return Column(
      children: [
        TurnBanner(
            myTurn: myTurn,
            currentPlayerName: roleOf(session.currentTurn)),
        Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: 9,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => tap(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      board[i],
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: board[i] == 'X'
                            ? Colors.pinkAccent
                            : Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Text('You are "$mySymbol"',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
      ],
    );
  }
}
