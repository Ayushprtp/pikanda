import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Turn-based memory match. 8 pairs (16 cards).
/// state = { "cards":[emoji…], "matched":[bool…], "flipped":[i,j],
///           "scores":{uid:n} }
class MemoryMatchBoard extends ConsumerStatefulWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;

  const MemoryMatchBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  @override
  ConsumerState<MemoryMatchBoard> createState() => _MemoryMatchBoardState();
}

class _MemoryMatchBoardState extends ConsumerState<MemoryMatchBoard>
    with GameBoardHelpers {
  @override
  List<GroupMember> get members => widget.members;

  static const _pool = ['🐼','⚡','🐰','🐱','🐧','🐉','🌈','🍓','🎈','⭐','🍀','🌸'];

  bool _resolving = false;

  List<String> get _cards {
    final raw = widget.session.state['cards'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).toList();
    }
    // Deterministic-ish first board seeded by session id.
    final rng = Random(widget.session.id.hashCode);
    final chosen = [..._pool]..shuffle(rng);
    final pairs = [...chosen.take(8), ...chosen.take(8)]..shuffle(rng);
    return pairs;
  }

  List<bool> get _matched {
    final raw = widget.session.state['matched'];
    if (raw is List && raw.length == 16) {
      return raw.map((e) => e == true).toList();
    }
    return List.filled(16, false);
  }

  List<int> get _flipped {
    final raw = widget.session.state['flipped'];
    if (raw is List) return raw.map((e) => e as int).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider)!;
    final myTurn = widget.session.currentTurn == myId;
    final cards = _cards;
    final matched = _matched;
    final flipped = _flipped;
    final scores = (widget.session.state['scores'] as Map?)?.cast<String, dynamic>() ?? {};

    Future<void> flip(int i) async {
      if (!myTurn || _resolving) return;
      if (matched[i] || flipped.contains(i) || flipped.length >= 2) return;

      final nowFlipped = [...flipped, i];

      if (nowFlipped.length < 2) {
        // First card of the turn — persist state, same player continues.
        await ref.read(gameControllerProvider).submitMove(
              widget.session.id,
              {'flip': i},
              newState: {
                'cards': cards,
                'matched': matched,
                'flipped': nowFlipped,
                'scores': scores,
              },
            );
        return;
      }

      // Second card — evaluate.
      setState(() => _resolving = true);
      final a = nowFlipped[0], b = nowFlipped[1];
      final isMatch = cards[a] == cards[b];
      final newMatched = [...matched];
      final newScores = {...scores};
      String? nextTurn;

      if (isMatch) {
        newMatched[a] = true;
        newMatched[b] = true;
        newScores[myId] = ((newScores[myId] ?? 0) as int) + 1;
        nextTurn = myId; // matched → go again
      } else {
        final other = widget.players
            .firstWhere((p) => p.userId != myId, orElse: () => widget.players.first)
            .userId;
        nextTurn = other;
      }

      final allMatched = newMatched.every((m) => m);
      String? winner;
      Map<String, int>? finalScores;
      if (allMatched) {
        var best = -1;
        newScores.forEach((uid, s) {
          final v = s as int;
          if (v > best) {
            best = v;
            winner = uid;
          }
        });
        finalScores = newScores.map((k, v) => MapEntry(k, v as int));
      }

      // Show the second card briefly before resolving for everyone.
      await ref.read(gameControllerProvider).submitMove(
            widget.session.id,
            {'flip': i},
            newState: {
              'cards': cards,
              'matched': matched,
              'flipped': nowFlipped,
              'scores': scores,
            },
          );
      await Future.delayed(const Duration(milliseconds: 900));
      await ref.read(gameControllerProvider).submitMove(
            widget.session.id,
            {'resolve': true},
            newState: {
              'cards': cards,
              'matched': newMatched,
              'flipped': [],
              'scores': newScores,
            },
            nextTurn: allMatched ? null : nextTurn,
            finish: allMatched,
            winner: winner,
            scores: finalScores,
          );
      if (mounted) setState(() => _resolving = false);
    }

    return Column(
      children: [
        TurnBanner(
            myTurn: myTurn,
            currentPlayerName: roleOf(widget.session.currentTurn)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            for (final p in widget.players)
              Chip(
                  label: Text(
                      '${roleOf(p.userId)}: ${scores[p.userId] ?? 0}')),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: 16,
              itemBuilder: (_, i) {
                final revealed = matched[i] || flipped.contains(i);
                return GestureDetector(
                  onTap: () => flip(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: matched[i]
                          ? Colors.green.withValues(alpha: 0.25)
                          : revealed
                              ? Colors.white.withValues(alpha: 0.12)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(revealed ? cards[i] : '❔',
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
