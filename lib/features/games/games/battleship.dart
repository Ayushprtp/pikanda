import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Battleship — 8×8, fleets of sizes 4/3/2/2 auto-placed (seeded from the
/// session id so both clients agree). Fire on your turn; a hit lets you go
/// again. Sink the whole enemy fleet to win.
/// state = { "fleets": {uid:[cells]}, "shots": {uid:[cells fired]} }
class BattleshipBoard extends ConsumerWidget with GameBoardHelpers {
  final GameSession session;
  final List<GamePlayer> players;
  @override
  final List<GroupMember> members;

  const BattleshipBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  static const n = 8;
  static const shipSizes = [4, 3, 2, 2];

  /// Deterministic fleet for a player index, seeded by session id.
  static List<int> fleetFor(String sessionId, int playerIndex) {
    final rng = Random(sessionId.hashCode ^ (playerIndex * 7919));
    final occupied = <int>{};
    for (final size in shipSizes) {
      while (true) {
        final horizontal = rng.nextBool();
        final row = rng.nextInt(horizontal ? n : n - size);
        final col = rng.nextInt(horizontal ? n - size : n);
        final cells = [
          for (var i = 0; i < size; i++)
            horizontal ? row * n + col + i : (row + i) * n + col
        ];
        if (cells.any(occupied.contains)) continue;
        occupied.addAll(cells);
        break;
      }
    }
    return occupied.toList()..sort();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(currentUserIdProvider)!;
    final myTurn = session.currentTurn == myId;
    final myIndex = players.indexWhere((p) => p.userId == myId);
    final opponent = players.firstWhere((p) => p.userId != myId,
        orElse: () => players.first);
    final oppIndex = players.indexOf(opponent);

    final myFleet = fleetFor(session.id, myIndex).toSet();
    final oppFleet = fleetFor(session.id, oppIndex).toSet();

    final shots = (session.state['shots'] as Map?) ?? {};
    final myShots =
        ((shots[myId] as List?) ?? []).map((e) => e as int).toSet();
    final oppShots =
        ((shots[opponent.userId] as List?) ?? []).map((e) => e as int).toSet();

    Future<void> fire(int cell) async {
      if (!myTurn || myShots.contains(cell)) return;
      final newMyShots = {...myShots, cell};
      final hit = oppFleet.contains(cell);
      final sunkAll = oppFleet.every(newMyShots.contains);

      await ref.read(gameControllerProvider).submitMove(
            session.id,
            {'fire': cell, 'hit': hit},
            newState: {
              'shots': {
                ...shots.map((k, v) => MapEntry(k.toString(), v)),
                myId: newMyShots.toList(),
              },
            },
            // classic rule: hit → shoot again; miss → pass turn
            nextTurn: sunkAll
                ? null
                : hit
                    ? myId
                    : opponent.userId,
            finish: sunkAll,
            winner: sunkAll ? myId : null,
            scores: sunkAll
                ? {
                    myId: newMyShots.where(oppFleet.contains).length,
                    opponent.userId:
                        oppShots.where(myFleet.contains).length,
                  }
                : null,
          );
    }

    Widget cellBox({
      required bool shot,
      required bool ship,
      required bool showShips,
      VoidCallback? onTap,
    }) {
      Color color;
      String label = '';
      if (shot && ship) {
        color = Colors.red.withValues(alpha: 0.8);
        label = '💥';
      } else if (shot) {
        color = Colors.blueGrey.withValues(alpha: 0.55);
        label = '·';
      } else if (ship && showShips) {
        color = Colors.teal.withValues(alpha: 0.6);
      } else {
        color = Colors.white.withValues(alpha: 0.07);
      }
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
          child: Center(
              child: Text(label, style: const TextStyle(fontSize: 10))),
        ),
      );
    }

    Widget grid({
      required Set<int> ships,
      required Set<int> shots,
      required bool showShips,
      required bool tappable,
    }) {
      return AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n),
          itemCount: n * n,
          itemBuilder: (_, i) => cellBox(
            shot: shots.contains(i),
            ship: ships.contains(i),
            showShips: showShips,
            onTap: tappable ? () => fire(i) : null,
          ),
        ),
      );
    }

    final myHitsOnThem = myShots.where(oppFleet.contains).length;
    final theirHitsOnMe = oppShots.where(myFleet.contains).length;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        TurnBanner(
            myTurn: myTurn, currentPlayerName: roleOf(session.currentTurn)),
        Text('🎯 Enemy waters — $myHitsOnThem/11 hits',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        grid(
            ships: oppFleet,
            shots: myShots,
            showShips: false,
            tappable: myTurn),
        const SizedBox(height: 14),
        Text('🚢 Your fleet — they hit $theirHitsOnMe/11',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        grid(
            ships: myFleet,
            shots: oppShots,
            showShips: true,
            tappable: false),
        const SizedBox(height: 8),
        Text('Hit = shoot again · fleets are auto-placed',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.45))),
      ],
    );
  }
}
