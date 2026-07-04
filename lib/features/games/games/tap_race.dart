import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Everyone taps as fast as they can for 10 seconds — simultaneous multiplayer.
/// state = { "taps": {uid: count}, "endsAt": iso, "started": bool }
class TapRaceBoard extends ConsumerStatefulWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;

  const TapRaceBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  @override
  ConsumerState<TapRaceBoard> createState() => _TapRaceBoardState();
}

class _TapRaceBoardState extends ConsumerState<TapRaceBoard>
    with GameBoardHelpers {
  @override
  List<GroupMember> get members => widget.members;

  int _localTaps = 0;
  DateTime? _endsAt;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Host sets the shared 10-second window if not set yet.
    final endsAtRaw = widget.session.state['endsAt'];
    if (endsAtRaw == null &&
        widget.session.createdBy == ref.read(currentUserIdProvider)) {
      final ends = DateTime.now().toUtc().add(const Duration(seconds: 10));
      ref.read(gameControllerProvider).submitMove(
        widget.session.id,
        {'start': true},
        newState: {'taps': {}, 'endsAt': ends.toIso8601String()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider)!;
    final taps = (widget.session.state['taps'] as Map?)?.cast<String, dynamic>() ?? {};
    final endsAtRaw = widget.session.state['endsAt'];
    _endsAt = endsAtRaw == null ? null : DateTime.parse(endsAtRaw).toLocal();

    if (_endsAt == null) {
      return const Center(child: Text('Waiting for host to start… ⏳'));
    }

    final remaining = _endsAt!.difference(DateTime.now()).inMilliseconds;
    final over = remaining <= 0;

    if (over && !_submitted) {
      _submitted = true;
      // Everyone submits their own final count. Host also finalizes winner.
      WidgetsBinding.instance.addPostFrameCallback((_) => _finalize(myId, taps));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(over ? '⏱️ Time!' : '👆 TAP TAP TAP!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        if (!over)
          _Countdown(endsAt: _endsAt!, onTick: () => setState(() {})),
        const SizedBox(height: 8),
        Text('Your taps: $_localTaps',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: over
                  ? null
                  : () => setState(() => _localTaps++),
              child: Container(
                decoration: BoxDecoration(
                  color: over
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(over ? '🏁' : '👆',
                      style: const TextStyle(fontSize: 100)),
                ),
              ),
            ),
          ),
        ),
        // live-ish standings (updates as players submit at the end)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            for (final p in widget.players)
              Chip(label: Text('${roleOf(p.userId)}: ${taps[p.userId] ?? '…'}')),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _finalize(String myId, Map<String, dynamic> taps) async {
    final newTaps = {...taps, myId: _localTaps};
    final everyone = widget.players.every((p) => newTaps.containsKey(p.userId));
    final isHost = widget.session.createdBy == myId;

    String? winner;
    Map<String, int>? scores;
    bool finish = false;
    if (everyone && isHost) {
      var best = -1;
      newTaps.forEach((uid, t) {
        final v = t as int;
        if (v > best) {
          best = v;
          winner = uid;
        }
      });
      scores = newTaps.map((k, v) => MapEntry(k, v as int));
      finish = true;
    }

    await ref.read(gameControllerProvider).submitMove(
          widget.session.id,
          {'final': _localTaps},
          newState: {'taps': newTaps, 'endsAt': widget.session.state['endsAt']},
          finish: finish,
          winner: winner,
          scores: scores,
        );
  }
}

class _Countdown extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback onTick;
  const _Countdown({required this.endsAt, required this.onTick});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  @override
  void initState() {
    super.initState();
    _loop();
  }

  Future<void> _loop() async {
    while (mounted && widget.endsAt.isAfter(DateTime.now())) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) widget.onTick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ms = widget.endsAt.difference(DateTime.now()).inMilliseconds;
    return Text('${(ms / 1000).clamp(0, 10).toStringAsFixed(1)}s',
        style: const TextStyle(fontSize: 18));
  }
}
