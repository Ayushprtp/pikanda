import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Reaction Duel — the screen turns red, then after a random delay flips green.
/// First to tap after green wins the round; tap too early and you lose it.
/// Best of 3.
/// state = { "round": n, "go_at": iso|null, "armed": bool, "wins": {uid:n},
///           "tapped": {uid: ms_after_go|-1 for early} }
class ReactionDuelBoard extends ConsumerStatefulWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;

  const ReactionDuelBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  @override
  ConsumerState<ReactionDuelBoard> createState() => _ReactionDuelBoardState();
}

class _ReactionDuelBoardState extends ConsumerState<ReactionDuelBoard>
    with GameBoardHelpers {
  @override
  List<GroupMember> get members => widget.members;

  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Host arms the first round with a random go-time.
    if (widget.session.state['go_at'] == null &&
        (widget.session.state['round'] ?? 0) == 0 &&
        widget.session.createdBy == ref.read(currentUserIdProvider)) {
      _armRound(1, {});
    }
    // Local ticker to refresh the countdown to green.
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _armRound(int round, Map wins) async {
    final delay = 1500 + Random().nextInt(3500); // 1.5–5s
    final goAt = DateTime.now().toUtc().add(Duration(milliseconds: delay));
    await ref.read(gameControllerProvider).submitMove(
      widget.session.id,
      {'arm': round},
      newState: {
        'round': round,
        'go_at': goAt.toIso8601String(),
        'armed': true,
        'wins': wins,
        'tapped': {},
      },
    );
  }

  Future<void> _tap(String myId, DateTime? goAt, Map tapped, Map wins, int round) async {
    if (tapped.containsKey(myId)) return;
    final now = DateTime.now().toUtc();
    final early = goAt == null || now.isBefore(goAt);
    final ms = early ? -1 : now.difference(goAt).inMilliseconds;
    HapticFeedback.mediumImpact();

    final newTapped = {...tapped, myId: ms};
    final everyone =
        widget.players.every((p) => newTapped.containsKey(p.userId));

    if (!everyone) {
      await ref.read(gameControllerProvider).submitMove(
        widget.session.id,
        {'tap': ms},
        newState: {
          'round': round,
          'go_at': goAt?.toIso8601String(),
          'armed': true,
          'wins': wins,
          'tapped': newTapped,
        },
      );
      return;
    }

    // Everyone tapped → decide round winner (fastest valid tap).
    String? roundWinner;
    var best = 1 << 30;
    newTapped.forEach((uid, v) {
      final t = v as int;
      if (t >= 0 && t < best) {
        best = t;
        roundWinner = uid;
      }
    });
    final newWins = {...wins};
    if (roundWinner != null) {
      newWins[roundWinner!] = ((newWins[roundWinner!] ?? 0) as int) + 1;
    }

    final maxWins = newWins.values.isEmpty
        ? 0
        : newWins.values.map((e) => e as int).reduce(max);
    final matchOver = maxWins >= 2 || round >= 3;

    if (matchOver) {
      String? winner;
      var bw = -1;
      newWins.forEach((uid, w) {
        if ((w as int) > bw) {
          bw = w;
          winner = uid;
        }
      });
      await ref.read(gameControllerProvider).submitMove(
        widget.session.id,
        {'result': best},
        newState: {
          'round': round,
          'go_at': null,
          'armed': false,
          'wins': newWins,
          'tapped': newTapped,
        },
        finish: true,
        winner: winner,
        scores: newWins.map((k, v) => MapEntry(k, v as int)),
      );
    } else {
      // Show the round result briefly, then arm the next round.
      await ref.read(gameControllerProvider).submitMove(
        widget.session.id,
        {'result': best},
        newState: {
          'round': round,
          'go_at': null,
          'armed': false,
          'wins': newWins,
          'tapped': newTapped,
        },
      );
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) await _armRound(round + 1, newWins);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider)!;
    final st = widget.session.state;
    final round = st['round'] ?? 1;
    final wins = (st['wins'] as Map?) ?? {};
    final tapped = (st['tapped'] as Map?) ?? {};
    final goAtRaw = st['go_at'];
    final goAt = goAtRaw == null ? null : DateTime.parse(goAtRaw);
    final now = DateTime.now().toUtc();
    final isGreen = goAt != null && now.isAfter(goAt);
    final iTapped = tapped.containsKey(myId);
    final armed = st['armed'] == true;

    final bg = !armed
        ? Colors.blueGrey.shade800
        : isGreen
            ? Colors.green.shade600
            : Colors.red.shade700;
    final label = !armed
        ? 'Get ready…'
        : iTapped
            ? (tapped[myId] == -1 ? 'Too early! ✗' : '${tapped[myId]} ms')
            : isGreen
                ? 'TAP!'
                : 'Wait for green…';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final p in widget.players)
                Column(children: [
                  Text(roleOf(p.userId)),
                  Text('${wins[p.userId] ?? 0}',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                ]),
            ],
          ),
        ),
        Text('Round $round · first to 2',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: (!armed || iTapped)
                  ? null
                  : () => _tap(myId, goAt, tapped, wins, round),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(28)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isGreen ? '⚡' : '✋',
                          style: const TextStyle(fontSize: 72)),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Tap the instant it turns green — but not before!',
              style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
