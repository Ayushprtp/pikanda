import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

final capsulesProvider = FutureProvider<List<MemoryCapsule>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('capsules_view')
      .select()
      .eq('group_id', gid)
      .order('created_at', ascending: false);
  return (rows as List)
      .map((r) => MemoryCapsule.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class CapsuleListScreen extends ConsumerWidget {
  const CapsuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsules = ref.watch(capsulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Capsules 📦')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/capsules/new'),
        icon: const Icon(Icons.add),
        label: const Text('Bury one'),
      ),
      body: capsules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) => list.isEmpty
            ? EmptyState(
                emoji: '📦',
                message:
                    'Bury a memory today.\nIt unlocks for everyone in 30 days.',
                actionLabel: 'Create a capsule',
                onAction: () => context.push('/capsules/new'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(capsulesProvider),
                child: ListView(
                  children: [for (final c in list) _CapsuleCard(capsule: c)],
                ),
              ),
      ),
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  final MemoryCapsule capsule;
  const _CapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    if (!capsule.isUnlocked) {
      final daysLeft =
          capsule.unlockAt.difference(DateTime.now()).inDays.clamp(0, 9999);
      return SectionCard(
        child: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sealed capsule',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Unlocks in $daysLeft days',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55))),
                  Text('sealed ${DateFormat.yMMMd().format(capsule.createdAt)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.35))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📭', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(capsule.title ?? 'A memory',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (capsule.imageUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _CapsuleImage(path: capsule.imageUrl!),
            ),
          ],
          if (capsule.content != null) ...[
            const SizedBox(height: 10),
            Text(capsule.content!, style: const TextStyle(fontSize: 15)),
          ],
          const SizedBox(height: 8),
          Text('buried ${DateFormat.yMMMd().format(capsule.createdAt)}',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _CapsuleImage extends ConsumerWidget {
  final String path;
  const _CapsuleImage({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref
        .watch(supabaseProvider)
        .storage
        .from('capsules')
        .createSignedUrl(path, 3600);
    return FutureBuilder<String>(
      future: future,
      builder: (_, snap) => snap.hasData
          ? CachedNetworkImage(
              imageUrl: snap.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180)
          : const SizedBox(
              height: 180, child: Center(child: CircularProgressIndicator())),
    );
  }
}

class CreateCapsuleScreen extends ConsumerStatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  ConsumerState<CreateCapsuleScreen> createState() =>
      _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends ConsumerState<CreateCapsuleScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  File? _image;
  int _days = 30;
  bool _busy = false;

  Future<void> _create() async {
    if (_title.text.trim().isEmpty && _content.text.trim().isEmpty) {
      showSnack(context, 'Add a title or a message');
      return;
    }
    setState(() => _busy = true);
    try {
      final sb = ref.read(supabaseProvider);
      final gid = ref.read(activeGroupIdProvider)!;
      final uid = ref.read(currentUserIdProvider)!;
      String? imagePath;
      if (_image != null) {
        imagePath = '$gid/$uid/${const Uuid().v4()}.jpg';
        await sb.storage.from('capsules').upload(imagePath, _image!,
            fileOptions: const FileOptions(contentType: 'image/jpeg'));
      }
      await sb.from('memory_capsules').insert({
        'group_id': gid,
        'created_by': uid,
        'title': _title.text.trim().isEmpty ? null : _title.text.trim(),
        'content': _content.text.trim().isEmpty ? null : _content.text.trim(),
        'image_url': imagePath,
        'unlock_at': DateTime.now()
            .toUtc()
            .add(Duration(days: _days))
            .toIso8601String(),
      });
      ref.invalidate(capsulesProvider);
      if (mounted) {
        showSnack(context, 'Capsule sealed 📦 — see you in $_days days!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed: $e');
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Memory Capsule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Text('📦', style: TextStyle(fontSize: 56))),
          const SizedBox(height: 16),
          TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _content,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
                labelText: 'Write to your future selves…',
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(_image!, height: 160, fit: BoxFit.cover),
            ),
          TextButton.icon(
            onPressed: () async {
              final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1440,
                  imageQuality: 85);
              if (picked != null) setState(() => _image = File(picked.path));
            },
            icon: const Icon(Icons.photo),
            label: Text(_image == null ? 'Add a photo' : 'Change photo'),
          ),
          const SizedBox(height: 12),
          Text('Unlock in: $_days days',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 365,
            divisions: 364,
            label: '$_days days',
            onChanged: (v) => setState(() => _days = v.round()),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final d in [7, 30, 90, 180, 365])
                ActionChip(
                    label: Text('${d}d'),
                    onPressed: () => setState(() => _days = d)),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _create,
            icon: const Icon(Icons.lock_clock),
            label: Text(_busy ? 'Sealing…' : 'Seal capsule'),
          ),
        ],
      ),
    );
  }
}
