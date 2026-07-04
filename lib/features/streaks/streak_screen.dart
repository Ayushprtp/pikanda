import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import '../mood/mood_provider.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(myStreakProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Streaks')),
      body: streakAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (s) {
          final today = DateTime.now();
          final checkedToday = s.lastCheckin != null &&
              s.lastCheckin!.year == today.year &&
              s.lastCheckin!.month == today.month &&
              s.lastCheckin!.day == today.day;
          final atRisk = !checkedToday && s.currentStreak > 0;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Duolingo-style flame
              Center(
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: Text(s.currentStreak > 0 ? '🔥' : '🪵',
                          style: const TextStyle(fontSize: 96)),
                    ),
                    Text('${s.currentStreak}',
                        style: const TextStyle(
                            fontSize: 56, fontWeight: FontWeight.w800)),
                    Text(
                        s.currentStreak == 1
                            ? 'day streak'
                            : 'days streak',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (atRisk)
                SectionCard(
                  color: Colors.orange.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your streak is at risk!',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                                s.freezeTokens > 0
                                    ? 'Log a mood today — or your freeze token (🧊 ${s.freezeTokens}) will auto-save you once.'
                                    : 'Log a mood today to keep it alive — no freeze tokens left!',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SectionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BigStat('🏔️', '${s.longestStreak}', 'longest'),
                    _BigStat('🧊', '${s.freezeTokens}', 'freeze tokens'),
                    _BigStat('💪', '${s.dareStreak}', 'dare streak'),
                  ],
                ),
              ),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How streaks work',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      '• Log your mood once a day to grow the flame\n'
                      '• Miss a day and the streak resets…\n'
                      '• …unless a freeze token 🧊 saves you (used automatically)\n'
                      '• You get 1 freeze token back every Monday\n'
                      '• Dares have their own separate streak 💪',
                      style: TextStyle(
                          height: 1.6,
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => context.push('/mood'),
                  icon: const Icon(Icons.add_reaction_outlined),
                  label: Text(checkedToday
                      ? 'Log another mood'
                      : 'Check in now'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _BigStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      Text(value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      Text(label,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
    ]);
  }
}
