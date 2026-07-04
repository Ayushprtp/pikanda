import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'doodle_canvas.dart';
import 'zap_provider.dart';

class SendZapScreen extends ConsumerStatefulWidget {
  const SendZapScreen({super.key});

  @override
  ConsumerState<SendZapScreen> createState() => _SendZapScreenState();
}

class _SendZapScreenState extends ConsumerState<SendZapScreen> {
  final _caption = TextEditingController();
  final _recorder = AudioRecorder();

  File? _image;
  List<DoodleStroke> _strokes = [];
  bool _doodleMode = false;
  Color _doodleColor = Colors.pinkAccent;
  String? _emoji;
  String? _receiverId; // null = whole group
  File? _voiceFile;
  int _voiceSeconds = 0;
  bool _recording = false;
  DateTime? _recordStart;
  bool _sending = false;

  static const _doodleColors = [
    Colors.pinkAccent,
    Colors.yellowAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
    Colors.white,
    Colors.black,
  ];
  static const _emojis = ['⚡', '❤️', '😂', '🥺', '🎉', '🐼', '🌈', '✨'];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1440, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _strokes = [];
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() {
        _recording = false;
        if (path != null) {
          _voiceFile = File(path);
          _voiceSeconds = DateTime.now()
              .difference(_recordStart ?? DateTime.now())
              .inSeconds
              .clamp(1, 10);
        }
      });
    } else {
      if (!await _recorder.hasPermission()) {
        if (mounted) showSnack(context, 'Microphone permission needed');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${const Uuid().v4()}.m4a';
      await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() {
        _recording = true;
        _recordStart = DateTime.now();
      });
      // Hard stop at 10 seconds (plan limit).
      Future.delayed(const Duration(seconds: 10), () {
        if (_recording && mounted) _toggleRecording();
      });
    }
  }

  Future<void> _send() async {
    if (_image == null &&
        _caption.text.trim().isEmpty &&
        _voiceFile == null &&
        _emoji == null) {
      showSnack(context, 'Add a photo, caption, emoji or voice note first');
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(zapControllerProvider).sendZap(
            image: _image,
            caption: _caption.text,
            emoji: _emoji,
            doodleStrokes: _strokes.isEmpty
                ? null
                : [for (final s in _strokes) s.toJson()],
            receiverId: _receiverId,
            voiceNote: _voiceFile,
            voiceDurationSeconds: _voiceSeconds,
          );
      if (mounted) {
        showSnack(context, 'Zap sent ⚡');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed to send: $e');
        setState(() => _sending = false);
      }
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final myId = ref.watch(currentUserIdProvider);
    final others = members.where((m) => m.userId != myId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send a Zap ⚡'),
        actions: [
          TextButton(
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- photo + doodle ----
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: const Color(0xFF1A1A22),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📸', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera),
                                label: const Text('Camera'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_image!, fit: BoxFit.cover),
                          IgnorePointer(
                            ignoring: !_doodleMode,
                            child: DoodleCanvas(
                              strokes: _strokes,
                              color: _doodleColor,
                              onChanged: (s) => setState(() => _strokes = s),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                IconButton.filledTonal(
                                  tooltip: 'Doodle',
                                  isSelected: _doodleMode,
                                  onPressed: () => setState(
                                      () => _doodleMode = !_doodleMode),
                                  icon: const Icon(Icons.brush),
                                ),
                                if (_strokes.isNotEmpty)
                                  IconButton.filledTonal(
                                    tooltip: 'Undo stroke',
                                    onPressed: () => setState(() => _strokes =
                                        _strokes.sublist(
                                            0, _strokes.length - 1)),
                                    icon: const Icon(Icons.undo),
                                  ),
                                IconButton.filledTonal(
                                  tooltip: 'Remove photo',
                                  onPressed: () => setState(() {
                                    _image = null;
                                    _strokes = [];
                                    _doodleMode = false;
                                  }),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (_doodleMode)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in _doodleColors)
                    GestureDetector(
                      onTap: () => setState(() => _doodleColor = c),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2,
                              color: _doodleColor == c
                                  ? Colors.white
                                  : Colors.transparent),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _caption,
            maxLength: 120,
            decoration: const InputDecoration(
                labelText: 'Caption', counterText: ''),
          ),
          const SizedBox(height: 12),
          // ---- emoji ----
          Wrap(
            spacing: 8,
            children: [
              for (final e in _emojis)
                ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 20)),
                  selected: _emoji == e,
                  onSelected: (sel) =>
                      setState(() => _emoji = sel ? e : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // ---- voice note ----
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: _toggleRecording,
                style: _recording
                    ? FilledButton.styleFrom(backgroundColor: Colors.red)
                    : null,
                icon: Icon(_recording ? Icons.stop : Icons.mic),
                label: Text(_recording
                    ? 'Recording… (max 10s)'
                    : _voiceFile != null
                        ? 'Voice note added (${_voiceSeconds}s)'
                        : 'Add voice note'),
              ),
              if (_voiceFile != null && !_recording)
                IconButton(
                  onPressed: () => setState(() {
                    _voiceFile = null;
                    _voiceSeconds = 0;
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // ---- receiver ----
          const Text('Send to', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Whole group 👥'),
                selected: _receiverId == null,
                onSelected: (_) => setState(() => _receiverId = null),
              ),
              for (final m in others)
                ChoiceChip(
                  avatar: MemberAvatar(member: m, radius: 11),
                  label: Text(m.roleName),
                  selected: _receiverId == m.userId,
                  onSelected: (_) => setState(() => _receiverId = m.userId),
                ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
