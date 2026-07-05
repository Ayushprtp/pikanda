import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool pending; // sent by me, not yet confirmed

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.pending = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'],
        senderId: j['sender_id'],
        content: j['content'],
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}

/// Group chat state. Live delivery rides Supabase **Realtime Broadcast**
/// (no schema needed, instant). Messages are *also* inserted into the
/// `messages` table when it exists, which adds history + push notifications —
/// if the table isn't there yet the insert quietly no-ops.
class ChatController extends Notifier<List<ChatMessage>> {
  RealtimeChannel? _channel;
  String? _joinedGroup;

  @override
  List<ChatMessage> build() {
    final gid = ref.watch(activeGroupIdProvider);
    if (gid != null && gid != _joinedGroup) {
      _joinedGroup = gid;
      _connect(gid);
    }
    ref.onDispose(() => _channel?.unsubscribe());
    return const [];
  }

  SupabaseClient get _sb => ref.read(supabaseProvider);

  Future<void> _connect(String gid) async {
    await _channel?.unsubscribe();
    _channel = _sb.channel('chat:$gid')
      ..onBroadcast(
        event: 'message',
        callback: (payload) {
          try {
            final m =
                ChatMessage.fromJson(payload.cast<String, dynamic>());
            _upsert(m);
          } catch (e) {
            debugPrint('chat broadcast parse failed: $e');
          }
        },
      )
      ..subscribe();
    await _loadHistory(gid);
  }

  Future<void> _loadHistory(String gid) async {
    try {
      final rows = await _sb
          .from('messages')
          .select()
          .eq('group_id', gid)
          .order('created_at', ascending: false)
          .limit(100);
      final history = (rows as List)
          .map((r) => ChatMessage.fromJson((r as Map).cast<String, dynamic>()))
          .toList()
          .reversed
          .toList();
      // merge: history first, keep any live messages that arrived meanwhile
      final liveIds = history.map((m) => m.id).toSet();
      state = [
        ...history,
        ...state.where((m) => !liveIds.contains(m.id)),
      ];
    } catch (e) {
      // messages table not migrated yet → live-only chat, still works
      debugPrint('chat history unavailable (migration pending): $e');
    }
  }

  void _upsert(ChatMessage m) {
    final i = state.indexWhere((x) => x.id == m.id);
    if (i >= 0) {
      state = [...state]..[i] = m;
    } else {
      state = [...state, m];
    }
  }

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    final gid = ref.read(activeGroupIdProvider);
    final uid = ref.read(currentUserIdProvider);
    if (gid == null || uid == null) return;

    final msg = ChatMessage(
      id: const Uuid().v4(),
      senderId: uid,
      content: content,
      createdAt: DateTime.now(),
      pending: true,
    );
    _upsert(msg); // optimistic

    final wire = {
      'id': msg.id,
      'group_id': gid,
      'sender_id': uid,
      'content': content,
      'created_at': msg.createdAt.toUtc().toIso8601String(),
    };

    // 1. instant delivery to everyone in the channel
    try {
      await _channel?.sendBroadcastMessage(event: 'message', payload: wire);
    } catch (e) {
      debugPrint('chat broadcast failed: $e');
    }

    // 2. persistence + push notification (no-op until migration 0012 applies)
    try {
      await _sb.from('messages').insert(wire);
    } catch (e) {
      debugPrint('chat persist skipped: $e');
    }

    _upsert(ChatMessage(
        id: msg.id,
        senderId: uid,
        content: content,
        createdAt: msg.createdAt));
  }
}

final chatProvider =
    NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);
