import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/aes_helper.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

class _Whisper {
  final String message;
  final DateTime createdAt;
  _Whisper(this.message, this.createdAt);
}

final _whispersProvider = FutureProvider<List<_Whisper>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('whispers')
      .select('message, created_at')
      .eq('group_id', gid)
      .order('created_at', ascending: false)
      .limit(50);
  return (rows as List)
      .map((r) => _Whisper(
          r['message'], DateTime.parse(r['created_at']).toLocal()))
      .toList();
});

/// Whisper — one-way anonymous messages to the group. The sender id is
/// AES-encrypted client-side, so not even the database shows who sent it.
class WhisperScreen extends ConsumerStatefulWidget {
  const WhisperScreen({super.key});

  @override
  ConsumerState<WhisperScreen> createState() => _WhisperScreenState();
}

class _WhisperScreenState extends ConsumerState<WhisperScreen> {
  final _text = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final msg = _text.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sending = true);
    try {
      final group = await ref.read(activeGroupProvider.future);
      final uid = ref.read(currentUserIdProvider)!;
      final aes = AesHelper.forGroup(group!.id, group.aesSalt);
      await ref.read(supabaseProvider).from('whispers').insert({
        'group_id': group.id,
        'encrypted_sender_id': aes.encryptText(uid),
        'message': msg,
      });
      _text.clear();
      ref.invalidate(_whispersProvider);
      if (mounted) showSnack(context, 'Whispered 🤍 (nobody knows it was you)');
    } catch (e) {
      if (mounted) showSnack(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final whispers = ref.watch(_whispersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Whisper 🤍')),
      body: Column(
        children: [
          SectionCard(
            child: Column(
              children: [
                Text(
                  'Say something to your group — completely anonymously.\n'
                  'No replies. No sender. Just the words.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _text,
                  maxLength: 240,
                  maxLines: 3,
                  minLines: 1,
                  decoration:
                      const InputDecoration(hintText: 'Whisper something…'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.volume_down),
                    label: const Text('Whisper it'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: whispers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      emoji: '🤫', message: 'No whispers yet…')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('“${list[i].message}”',
                                style: const TextStyle(
                                    fontSize: 16, height: 1.4)),
                            const SizedBox(height: 6),
                            Text(
                                'someone in your group · ${list[i].createdAt.day}/${list[i].createdAt.month}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.4))),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
