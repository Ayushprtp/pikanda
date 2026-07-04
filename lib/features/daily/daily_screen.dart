import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'daily_provider.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thought = ref.watch(todayThoughtProvider);
    final dare = ref.watch(todayDareProvider);
    final messages = ref.watch(activeScheduledMessagesProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily 📅')),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayThoughtProvider);
              ref.invalidate(todayDareProvider);
              ref.invalidate(activeScheduledMessagesProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // ---- morning/night messages ----
                messages.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => list.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            for (final m in list)
                              SectionCard(
                                child: Row(
                                  children: [
                                    Text(
                                        m.sendTime.startsWith('0') ||
                                                int.tryParse(m.sendTime
                                                            .split(':')
                                                            .first) !=
                                                        null &&
                                                    int.parse(m.sendTime
                                                            .split(':')
                                                            .first) <
                                                        12
                                            ? '🌅'
                                            : '🌙',
                                        style: const TextStyle(fontSize: 26)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m.message,
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          Text(
                                              'daily · ${m.sendTime.substring(0, 5)}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white
                                                      .withValues(
                                                          alpha: 0.4))),
                                        ],
                                      ),
                                    ),
                                    if (isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18),
                                        onPressed: () => ref
                                            .read(dailyControllerProvider)
                                            .deleteScheduledMessage(m.id),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                // ---- thought of the day ----
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💭 Thought of the day',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _editText(
                                  'Thought of the day',
                                  (t) => ref
                                      .read(dailyControllerProvider)
                                      .setThought(t)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      thought.when(
                        loading: () =>
                            const Text('…', style: TextStyle(fontSize: 16)),
                        error: (_, __) => const Text('—'),
                        data: (t) => Text(
                            t?.thought ?? 'No thought set yet today',
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: t == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: t == null
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : Colors.white)),
                      ),
                    ],
                  ),
                ),
                // ---- dare of the day ----
                dare.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (d) {
                    final done = d != null && myId != null &&
                        d.completedBy.contains(myId);
                    return SectionCard(
                      color:
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💪 Dare of the day',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _editText(
                                      'Dare of the day',
                                      (t) => ref
                                          .read(dailyControllerProvider)
                                          .setDare(t)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(d?.dareText ?? 'No dare set yet today',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: d == null
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.white)),
                          if (d != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: done
                                      ? null
                                      : () async {
                                          await ref
                                              .read(dailyControllerProvider)
                                              .completeDare(d.id);
                                          _confetti.play();
                                        },
                                  icon: Icon(done
                                      ? Icons.check_circle
                                      : Icons.emoji_events),
                                  label: Text(done ? 'Completed!' : 'Mark done'),
                                ),
                                const SizedBox(width: 12),
                                Text('${d.completedBy.length} done',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.5))),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => _addScheduled(),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Schedule a morning/night message'),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 24,
              colors: const [
                Colors.pink,
                Colors.amber,
                Colors.lightBlue,
                Colors.greenAccent,
                Colors.purpleAccent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editText(String title, Future<void> Function(String) onSave) {
    final ctl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(title),
        content: TextField(
            controller: ctl,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Type here…')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctl.text.trim().isNotEmpty) {
                await onSave(ctl.text.trim());
              }
              if (dCtx.mounted) Navigator.pop(dCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addScheduled() {
    final ctl = TextEditingController();
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setLocal) => AlertDialog(
          title: const Text('Scheduled message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: ctl,
                  maxLines: 2,
                  minLines: 1,
                  decoration:
                      const InputDecoration(hintText: 'Good morning group! ☀️')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Send at ${time.format(dCtx)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: dCtx, initialTime: time);
                      if (picked != null) setLocal(() => time = picked);
                    },
                    child: const Text('Pick time'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (ctl.text.trim().isNotEmpty) {
                  final t =
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                  await ref
                      .read(dailyControllerProvider)
                      .addScheduledMessage(ctl.text.trim(), t);
                }
                if (dCtx.mounted) Navigator.pop(dCtx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
