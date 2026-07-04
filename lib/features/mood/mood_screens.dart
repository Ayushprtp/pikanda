import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../groups/group_provider.dart';
import 'mood_provider.dart';

// ============================ Mood Picker ============================

class MoodPickerScreen extends ConsumerStatefulWidget {
  const MoodPickerScreen({super.key});

  @override
  ConsumerState<MoodPickerScreen> createState() => _MoodPickerScreenState();
}

class _MoodPickerScreenState extends ConsumerState<MoodPickerScreen> {
  bool _busy = false;

  Future<void> _pick(Mood mood) async {
    setState(() => _busy = true);
    try {
      final result = await ref.read(moodControllerProvider).logMood(mood);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MoodResultScreen(mood: mood, result: result)));
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Could not log mood: $e');
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(moodLabelsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('How are you feeling?')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                for (final mood in Mood.values)
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _pick(mood),
                    child: Container(
                      decoration: BoxDecoration(
                        color: mood.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: mood.color.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood.emoji,
                              style: const TextStyle(fontSize: 52)),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              mood.label(labels),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ============================ Mood Result ============================

class MoodResultScreen extends ConsumerWidget {
  final Mood mood;
  final MoodResult result;

  const MoodResultScreen(
      {super.key, required this.mood, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(moodLabelsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text('${mood.emoji} ${mood.label(labels)}')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          SectionCard(
            color: mood.color.withValues(alpha: 0.14),
            child: Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 40)),
                Text('${result.streak.currentStreak} day streak!',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                Text('longest: ${result.streak.longestStreak} days',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55))),
              ],
            ),
          ),
          if (result.quote != null)
            SectionCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('💬', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 10),
                  Text(
                    result.quote!.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ],
              ),
            ),
          if (result.song != null)
            SectionCard(
              onTap: () => launchUrl(Uri.parse(result.song!.url),
                  mode: LaunchMode.externalApplication),
              child: Row(
                children: [
                  Text(result.song!.platform == 'spotify' ? '🎧' : '▶️',
                      style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.song!.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        if (result.song!.artist != null)
                          Text(result.song!.artist!,
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Colors.white.withValues(alpha: 0.55))),
                        Text('a song for this mood — tap to play',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 18),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ Mood Calendar ============================

class MoodCalendarScreen extends ConsumerWidget {
  const MoodCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ref.watch(myCalendarMoodsProvider);
    final streak = ref.watch(myStreakProvider).valueOrNull;
    final labels = ref.watch(moodLabelsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Calendar')),
      body: moods.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (entries) {
          // last mood of each day wins
          final byDay = <DateTime, Mood>{};
          for (final e in entries) {
            final d =
                DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day);
            byDay[d] = e.mood;
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              SectionCard(
                child: _ContributionGrid(
                    byDay: byDay,
                    onDayTap: (day) {
                      final list = entries
                          .where((e) =>
                              e.loggedAt.year == day.year &&
                              e.loggedAt.month == day.month &&
                              e.loggedAt.day == day.day)
                          .toList();
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${day.day}/${day.month}/${day.year}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              if (list.isEmpty)
                                const Text('No mood logged this day'),
                              for (final e in list)
                                ListTile(
                                  leading: Text(e.mood.emoji,
                                      style: const TextStyle(fontSize: 26)),
                                  title: Text(e.mood.label(labels)),
                                  trailing: Text(
                                      '${e.loggedAt.hour.toString().padLeft(2, '0')}:${e.loggedAt.minute.toString().padLeft(2, '0')}'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              if (streak != null)
                SectionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat('🔥', '${streak.currentStreak}', 'current'),
                      _Stat('🏔️', '${streak.longestStreak}', 'longest'),
                      _Stat('🧊', '${streak.freezeTokens}', 'freeze left'),
                    ],
                  ),
                ),
              SectionCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    for (final m in Mood.values)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: m.color,
                                borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 4),
                        Text(m.label(labels),
                            style: const TextStyle(fontSize: 12)),
                      ]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _Stat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      Text(value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      Text(label,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
    ]);
  }
}

/// GitHub-contribution-style grid: columns of weeks × 7 rows of days.
class _ContributionGrid extends StatelessWidget {
  final Map<DateTime, Mood> byDay;
  final void Function(DateTime day) onDayTap;

  const _ContributionGrid({required this.byDay, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    var start = end.subtract(const Duration(days: 7 * 16));
    start = start.subtract(Duration(days: start.weekday - 1));

    final weeks = <List<DateTime?>>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      final week = <DateTime?>[];
      for (var d = 0; d < 7; d++) {
        final day = cursor.add(Duration(days: d));
        week.add(day.isAfter(end) ? null : day);
      }
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final week in weeks)
            Column(
              children: [
                for (final day in week)
                  GestureDetector(
                    onTap: day == null ? null : () => onDayTap(day),
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: day == null
                            ? Colors.transparent
                            : byDay[day]?.color ??
                                Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
