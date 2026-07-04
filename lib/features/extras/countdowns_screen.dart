import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

final countdownsProvider = FutureProvider<List<CountdownEvent>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('countdown_events')
      .select()
      .eq('group_id', gid);
  final list = (rows as List)
      .map((r) => CountdownEvent.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
  list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  return list;
});

class CountdownsScreen extends ConsumerWidget {
  const CountdownsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(countdownsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Countdowns ⏳')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add event'),
      ),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) => list.isEmpty
            ? EmptyState(
                emoji: '🎂',
                message: 'Birthdays, anniversaries, trips…\nCount down together',
                actionLabel: 'Add an event',
                onAction: () => _add(context, ref))
            : ListView(
                children: [
                  for (final e in list)
                    Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await ref
                            .read(supabaseProvider)
                            .from('countdown_events')
                            .delete()
                            .eq('id', e.id);
                        ref.invalidate(countdownsProvider);
                      },
                      child: SectionCard(
                        child: Row(
                          children: [
                            Text(e.emoji ?? '🎉',
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      DateFormat.yMMMMd()
                                          .format(e.nextOccurrence),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white
                                              .withValues(alpha: 0.5))),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text('${e.daysLeft}',
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800)),
                                Text(e.daysLeft == 1 ? 'day' : 'days',
                                    style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _add(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final emoji = TextEditingController(text: '🎂');
    DateTime date = DateTime.now().add(const Duration(days: 30));
    bool yearly = true;
    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setLocal) => AlertDialog(
          title: const Text('New countdown'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: TextField(
                        controller: emoji, textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                        controller: title,
                        decoration:
                            const InputDecoration(hintText: 'Event name')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(DateFormat.yMMMd().format(date))),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dCtx,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setLocal(() => date = picked);
                    },
                    child: const Text('Pick date'),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Repeats yearly'),
                value: yearly,
                onChanged: (v) => setLocal(() => yearly = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                final gid = ref.read(activeGroupIdProvider)!;
                final uid = ref.read(currentUserIdProvider)!;
                await ref
                    .read(supabaseProvider)
                    .from('countdown_events')
                    .insert({
                  'group_id': gid,
                  'title': title.text.trim(),
                  'emoji': emoji.text.trim(),
                  'event_date':
                      DateFormat('yyyy-MM-dd').format(date),
                  'repeats_yearly': yearly,
                  'created_by': uid,
                });
                ref.invalidate(countdownsProvider);
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
