import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import '../zap/zap_provider.dart';

/// All photo zaps ever, for the gallery (larger window than the inbox).
final memoriesProvider = FutureProvider<List<Zap>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('zaps')
      .select()
      .eq('group_id', gid)
      .not('image_url', 'is', null)
      .order('created_at', ascending: false)
      .limit(500);
  return (rows as List)
      .map((r) => Zap.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// Photo gallery of every zap, grouped by month, with an "on this day" strip.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];

    String roleOf(String uid) {
      for (final m in members) {
        if (m.userId == uid) return m.roleName;
      }
      return 'someone';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memories 🖼️')),
      body: memories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (zaps) {
          if (zaps.isEmpty) {
            return const EmptyState(
                emoji: '🖼️',
                message: 'Every photo zap you send\nbecomes a memory here');
          }

          final today = DateTime.now();
          final onThisDay = zaps
              .where((z) =>
                  z.createdAt.day == today.day &&
                  z.createdAt.month == today.month &&
                  !(z.createdAt.year == today.year &&
                      z.createdAt.month == today.month &&
                      z.createdAt.day == today.day))
              .toList();

          final byMonth = <String, List<Zap>>{};
          for (final z in zaps) {
            final key = DateFormat('MMMM yyyy').format(z.createdAt);
            byMonth.putIfAbsent(key, () => []).add(z);
          }

          return ListView(
            children: [
              if (onThisDay.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text('📅 On this day',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final z in onThisDay)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              _Thumb(zap: z, size: 100, onTap: () =>
                                  _openViewer(context, z, roleOf(z.senderId))),
                              Text('${today.year - z.createdAt.year}y ago',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              for (final entry in byMonth.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Text(entry.key,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    for (final z in entry.value)
                      _Thumb(
                          zap: z,
                          onTap: () =>
                              _openViewer(context, z, roleOf(z.senderId))),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, Zap zap, String sender) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _FullImage(path: zap.imageUrl!),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  if (zap.caption != null)
                    Text(zap.caption!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16)),
                  Text(
                      '$sender · ${DateFormat.yMMMMd().format(zap.createdAt)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  final Zap zap;
  final double? size;
  final VoidCallback onTap;
  const _Thumb({required this.zap, this.size, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(signedUrlProvider(('zaps', zap.imageUrl!)));
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: size,
          height: size,
          child: url.when(
            loading: () => Container(color: Colors.white10),
            error: (_, __) => Container(
                color: Colors.white10, child: const Icon(Icons.broken_image)),
            data: (u) => CachedNetworkImage(imageUrl: u, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _FullImage extends ConsumerWidget {
  final String path;
  const _FullImage({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(signedUrlProvider(('zaps', path)));
    return url.when(
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.broken_image, size: 64),
      data: (u) => CachedNetworkImage(imageUrl: u, fit: BoxFit.contain),
    );
  }
}
