import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Connect Four — 7 columns × 6 rows. Drop a disc into a column; first to
/// four-in-a-row (horiz/vert/diag) wins.
/// state = { "board": [42 cells: "", "R", "Y"] }  (row 0 = bottom)
/// players[0] = R (red), players[1] = Y (yellow)
class Connect4Board extends ConsumerWidget with GameBoardHelpers {
  final GameSession session;
  final List<GamePlayer> players;
  @override
  final List<GroupMember> members;

  const Connect4Board({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  static const cols = 7;
  static const rows = 6;

  List<String> get _board {
    final raw = session.state['board'];
    if (raw is List && raw.length == cols * rows) {
      return raw.map((e) => e.toString()).toList();
    }
    return List.filled(cols * rows, '');
  }

  int _idx(int col, int row) => row * cols + col;

  String _discFor(String uid) =>
      players.indexWhere((p) => p.userId == uid) == 0 ? 'R' : 'Y';

  /// Lowest empty row in a column, or -1 if full.
  int _dropRow(List<String> b, int col) {
    for (var r = 0; r < rows; r++) {
      if (b[_idx(col, r)].isEmpty) return r;
    }
    return -1;
  }

  bool _wins(List<String> b, String disc) {
    for (var c = 0; c < cols; c++) {
      for (var r = 0; r < rows; r++) {
        if (b[_idx(c, r)] != disc) continue;
        for (final dir in const [[1, 0], [0, 1], [1, 1], [1, -1]]) {
          var count = 0, cc = c, rr = r;
          while (cc >= 0 && cc < cols && rr >= 0 && rr < rows &&
              b[_idx(cc, rr)] == disc) {
            count++;
            if (count >= 4) return true;
            cc += dir[0];
            rr += dir[1];
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(currentUserIdProvider);
    final myTurn = session.currentTurn == myId;
    final board = _board;
    final disc = myId == null ? '' : _discFor(myId);

    Future<void> drop(int col) async {
      if (!myTurn) return;
      final row = _dropRow(board, col);
      if (row < 0) return;
      final next = [...board];
      next[_idx(col, row)] = disc;
      final win = _wins(next, disc);
      final full = !next.contains('');
      final finish = win || full;
      final other = players.firstWhere((p) => p.userId != myId,
          orElse: () => players.first).userId;

      await ref.read(gameControllerProvider).submitMove(
            session.id,
            {'col': col, 'disc': disc},
            newState: {'board': next},
            nextTurn: finish ? null : other,
            finish: finish,
            winner: win ? myId : null,
            scores: win ? {myId!: 1} : null,
          );
    }

    return Column(
      children: [
        TurnBanner(myTurn: myTurn, currentPlayerName: roleOf(session.currentTurn)),
        Text('You are ${disc == 'R' ? '🔴 Red' : '🟡 Yellow'}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: cols / rows,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    for (var c = 0; c < cols; c++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => drop(c),
                          child: Column(
                            children: [
                              // render top row first (row index rows-1 .. 0)
                              for (var r = rows - 1; r >= 0; r--)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: switch (board[_idx(c, r)]) {
                                          'R' => Colors.red,
                                          'Y' => Colors.amber,
                                          _ => const Color(0xFF0D0D12),
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Tap a column to drop your disc',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
        ),
      ],
    );
  }
}
