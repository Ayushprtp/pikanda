import 'package:flutter/material.dart';
import '../../../shared/models.dart';

/// Helpers shared by all game boards.
mixin GameBoardHelpers {
  List<GroupMember> get members;

  String roleOf(String? uid) {
    for (final m in members) {
      if (m.userId == uid) return m.roleName;
    }
    return 'player';
  }
}

class TurnBanner extends StatelessWidget {
  final bool myTurn;
  final String currentPlayerName;
  const TurnBanner({super.key, required this.myTurn, required this.currentPlayerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: myTurn
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        myTurn ? 'Your turn!' : 'Waiting for $currentPlayerName…',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: myTurn ? Theme.of(context).colorScheme.primary : null),
      ),
    );
  }
}
