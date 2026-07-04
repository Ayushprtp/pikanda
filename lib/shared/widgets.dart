import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/safezap/safezap_service.dart';
import 'models.dart';

/// Rounded content card used across all screens.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(20), child: card);
  }
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// App logo. Tapping it 3 times within 1.5s silently fires the SafeZap
/// safe-word trigger — no UI feedback at all, by design.
class PikandaLogo extends ConsumerStatefulWidget {
  final double size;
  const PikandaLogo({super.key, this.size = 28});

  @override
  ConsumerState<PikandaLogo> createState() => _PikandaLogoState();
}

class _PikandaLogoState extends ConsumerState<PikandaLogo> {
  int _taps = 0;
  Timer? _resetTimer;

  void _onTap() {
    _taps++;
    _resetTimer?.cancel();
    if (_taps >= 3) {
      _taps = 0;
      // Completely silent: no snackbar, no haptic, no navigation.
      unawaited(ref.read(safeZapServiceProvider).triggerSafeWord());
    } else {
      _resetTimer = Timer(const Duration(milliseconds: 1500), () => _taps = 0);
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Text('🐼⚡', style: TextStyle(fontSize: widget.size)),
    );
  }
}

/// Circle avatar for a member: photo if set, otherwise initial letter.
class MemberAvatar extends StatelessWidget {
  final GroupMember? member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final url = member?.user?.avatarUrl;
    final label = member?.roleName ?? '?';
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      child: Text(label.isEmpty ? '?' : label[0].toUpperCase(),
          style: TextStyle(fontSize: radius * 0.9, color: Colors.white)),
    );
  }
}

/// Animated gradient ring around an avatar based on 30-day mood mix.
class AuraRing extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double thickness;

  const AuraRing({
    super.key,
    required this.child,
    required this.colors,
    this.thickness = 3.5,
  });

  @override
  State<AuraRing> createState() => _AuraRingState();
}

class _AuraRingState extends State<AuraRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))
    ..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, child) => Container(
        padding: EdgeInsets.all(widget.thickness),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [...widget.colors, widget.colors.first],
            transform: GradientRotation(_ctl.value * 6.28318),
          ),
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Computes aura colors from mood history (last 30 days).
List<Color> auraColors(List<MoodEntry> entries) {
  if (entries.isEmpty) return [Colors.grey.shade600, Colors.grey.shade800];
  final counts = <Mood, int>{};
  for (final e in entries) {
    counts[e.mood] = (counts[e.mood] ?? 0) + 1;
  }
  final total = entries.length;
  for (final entry in counts.entries) {
    if (entry.value / total > 0.6) {
      return switch (entry.key) {
        Mood.happy => [const Color(0xFFFFD700), const Color(0xFFFFA000)],
        Mood.sad => [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
        Mood.excited => [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
        Mood.anxious => [const Color(0xFFFFC107), const Color(0xFFFFECB3)],
        Mood.angry => [const Color(0xFFF44336), const Color(0xFFB71C1C)],
        Mood.neutral => [Colors.grey.shade400, Colors.grey.shade700],
      };
    }
  }
  // Mixed → rainbow
  return const [
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFFFFEB3B),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
  ];
}

class StreakBadge extends StatelessWidget {
  final int streak;
  final double fontSize;

  const StreakBadge({super.key, required this.streak, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: streak > 0
            ? Colors.deepOrange.withValues(alpha: 0.25)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('🔥 $streak',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }
}

/// Stat bar for pet stats etc.
class StatBar extends StatelessWidget {
  final String label;
  final String emoji;
  final int value; // 0-100
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(emoji)),
          SizedBox(
              width: 84,
              child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: value < 25 ? Colors.red : color,
              ),
            ),
          ),
          SizedBox(
              width: 36,
              child: Text(' $value',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
