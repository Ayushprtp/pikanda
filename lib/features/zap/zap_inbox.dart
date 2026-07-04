import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'doodle_canvas.dart';
import 'zap_provider.dart';

/// Zap inbox — the body of the "Zaps" tab.
class ZapInboxBody extends ConsumerWidget {
  const ZapInboxBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(zapRealtimeProvider); // keep realtime alive
    final zaps = ref.watch(zapsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/zap/send'),
        icon: const Icon(Icons.bolt),
        label: const Text('Zap'),
      ),
      body: zaps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
            emoji: '😵',
            message: 'Could not load zaps: $e',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(zapsProvider)),
        data: (list) => list.isEmpty
            ? EmptyState(
                emoji: '⚡',
                message:
                    'No zaps yet.\nSend the first one — it lands on their home screen!',
                actionLabel: 'Send a Zap',
                onAction: () => context.push('/zap/send'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(zapsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: list.length,
                  itemBuilder: (_, i) => ZapCard(zap: list[i]),
                ),
              ),
      ),
    );
  }
}

class ZapCard extends ConsumerWidget {
  final Zap zap;
  const ZapCard({super.key, required this.zap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final myId = ref.watch(currentUserIdProvider);
    GroupMember? findMember(String? id) {
      for (final m in members) {
        if (m.userId == id) return m;
      }
      return null;
    }

    final sender = findMember(zap.senderId);
    final receiver = findMember(zap.receiverId);
    final strokes = DoodleStroke.listFromRaw(zap.doodleData);

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context, ref),
      child: SectionCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MemberAvatar(member: sender, radius: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${sender?.roleName ?? 'Someone'}'
                          '${receiver != null ? ' → ${zap.receiverId == myId ? 'you' : receiver.roleName}' : ''}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      Text(_ago(zap.createdAt),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.45))),
                    ],
                  ),
                ),
                if (zap.emoji != null)
                  Text(zap.emoji!, style: const TextStyle(fontSize: 26)),
              ],
            ),
            if (zap.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _SignedImage(bucket: 'zaps', path: zap.imageUrl!),
                      if (strokes.isNotEmpty)
                        IgnorePointer(
                          child: CustomPaint(
                              painter: DoodlePainter(strokes: strokes)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (zap.caption != null) ...[
              const SizedBox(height: 8),
              Text(zap.caption!, style: const TextStyle(fontSize: 15)),
            ],
            if (zap.voiceNote != null) ...[
              const SizedBox(height: 8),
              _VoiceNotePlayer(note: zap.voiceNote!),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (zap.reactions.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: [
                      for (final r in zap.reactions)
                        Tooltip(
                          message: findMember(r.userId)?.roleName ?? '',
                          child: Text(r.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showReactionPicker(context, ref),
                  icon: const Icon(Icons.add_reaction_outlined, size: 18),
                  label: const Text('React'),
                ),
                if (zap.senderId != myId)
                  TextButton.icon(
                    onPressed: () => context.push('/zap/send'),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: const Text('Zap back'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final e in zapReactionEmojis)
              GestureDetector(
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await ref.read(zapControllerProvider).react(zap.id, e);
                },
                child: Text(e, style: const TextStyle(fontSize: 36)),
              ),
          ],
        ),
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

/// Resolves a private-bucket path to a signed URL and renders it.
class _SignedImage extends ConsumerWidget {
  final String bucket;
  final String path;
  const _SignedImage({required this.bucket, required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(signedUrlProvider((bucket, path)));
    return url.when(
      loading: () => Container(
          color: Colors.white10,
          child: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Container(
          color: Colors.white10,
          child: const Center(child: Icon(Icons.broken_image))),
      data: (u) => CachedNetworkImage(imageUrl: u, fit: BoxFit.cover),
    );
  }
}

class _VoiceNotePlayer extends ConsumerStatefulWidget {
  final VoiceNote note;
  const _VoiceNotePlayer({required this.note});

  @override
  ConsumerState<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends ConsumerState<_VoiceNotePlayer> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((s) {
      if (mounted) {
        setState(() =>
            _playing = s.playing && s.processingState != ProcessingState.completed);
      }
    });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    if (_player.audioSource == null) {
      final url = await ref
          .read(supabaseProvider)
          .storage
          .from('voice-notes')
          .createSignedUrl(widget.note.storageUrl, 3600);
      await _player.setUrl(url);
    }
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            onPressed: _toggle,
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          _Waveform(playing: _playing),
          const SizedBox(width: 10),
          Text('${widget.note.durationSeconds}s 🎙️'),
        ],
      ),
    );
  }
}

/// Lightweight animated waveform bars.
class _Waveform extends StatefulWidget {
  final bool playing;
  const _Waveform({required this.playing});

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  static const _heights = [8.0, 16.0, 12.0, 22.0, 10.0, 18.0, 14.0, 20.0, 9.0];

  @override
  void didUpdateWidget(covariant _Waveform old) {
    super.didUpdateWidget(old);
    widget.playing ? _ctl.repeat(reverse: true) : _ctl.stop();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _heights.length; i++)
            Container(
              width: 3,
              height: widget.playing
                  ? _heights[i] * (0.5 + 0.5 * ((_ctl.value + i / 9) % 1.0))
                  : _heights[i] * 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
