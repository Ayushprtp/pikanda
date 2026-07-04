import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

final bucketListProvider = FutureProvider<List<BucketItem>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('bucket_list')
      .select()
      .eq('group_id', gid)
      .order('is_done')
      .order('created_at', ascending: false);
  return (rows as List)
      .map((r) => BucketItem.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class BucketListScreen extends ConsumerWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bucketListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bucket List 🪣')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add dream'),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) => list.isEmpty
            ? EmptyState(
                emoji: '🪣',
                message: 'Things you want to do together.\nAdd your first!',
                actionLabel: 'Add one',
                onAction: () => _add(context, ref))
            : ListView(
                children: [
                  for (final item in list)
                    Dismissible(
                      key: ValueKey(item.id),
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
                            .from('bucket_list')
                            .delete()
                            .eq('id', item.id);
                        ref.invalidate(bucketListProvider);
                      },
                      child: CheckboxListTile(
                        value: item.isDone,
                        title: Text(
                          '${item.emoji ?? '⭐'}  ${item.title}',
                          style: TextStyle(
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isDone
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.white,
                          ),
                        ),
                        onChanged: (v) async {
                          await ref
                              .read(supabaseProvider)
                              .from('bucket_list')
                              .update({
                            'is_done': v ?? false,
                            'done_at': (v ?? false)
                                ? DateTime.now().toUtc().toIso8601String()
                                : null,
                          }).eq('id', item.id);
                          ref.invalidate(bucketListProvider);
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _add(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final emoji = TextEditingController(text: '⭐');
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('New bucket-list item'),
        content: Row(
          children: [
            SizedBox(
              width: 56,
              child: TextField(
                controller: emoji,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '⭐'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Watch the sunrise…'),
              ),
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
              await ref.read(supabaseProvider).from('bucket_list').insert({
                'group_id': gid,
                'title': title.text.trim(),
                'emoji': emoji.text.trim().isEmpty ? '⭐' : emoji.text.trim(),
                'created_by': uid,
              });
              ref.invalidate(bucketListProvider);
              if (dCtx.mounted) Navigator.pop(dCtx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
