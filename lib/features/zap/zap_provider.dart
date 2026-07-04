import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// Latest zaps for the active group (with reactions + voice notes).
final zapsProvider = FutureProvider<List<Zap>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('zaps')
      .select('*, zap_reactions(*), voice_notes(*)')
      .eq('group_id', gid)
      .order('created_at', ascending: false)
      .limit(60);
  return (rows as List)
      .map((r) => Zap.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// Realtime: any change to this group's zaps/reactions refreshes the inbox.
final zapRealtimeProvider = Provider<void>((ref) {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return;
  final channel = ref
      .watch(supabaseProvider)
      .channel('zaps:$gid')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'zaps',
        filter:
            PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'group_id', value: gid),
        callback: (_) => ref.invalidate(zapsProvider),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'zap_reactions',
        callback: (_) => ref.invalidate(zapsProvider),
      )
      .subscribe();
  ref.onDispose(() => channel.unsubscribe());
});

/// Signed URL cache for private storage objects.
final signedUrlProvider =
    FutureProvider.family<String, (String bucket, String path)>((ref, key) {
  return ref
      .watch(supabaseProvider)
      .storage
      .from(key.$1)
      .createSignedUrl(key.$2, 3600);
});

class ZapController {
  final Ref ref;
  ZapController(this.ref);

  SupabaseClient get _sb => ref.read(supabaseProvider);

  Future<void> sendZap({
    File? image,
    String? caption,
    String? emoji,
    List<Map<String, dynamic>>? doodleStrokes,
    String? receiverId,
    File? voiceNote,
    int voiceDurationSeconds = 0,
  }) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    final id = const Uuid().v4();

    String? imagePath;
    if (image != null) {
      imagePath = '$gid/$uid/$id.jpg';
      await _sb.storage.from('zaps').upload(imagePath, image,
          fileOptions: const FileOptions(contentType: 'image/jpeg'));
    }

    final zapRow = await _sb
        .from('zaps')
        .insert({
          'group_id': gid,
          'sender_id': uid,
          'receiver_id': receiverId,
          'image_url': imagePath,
          'caption': caption?.trim().isEmpty ?? true ? null : caption!.trim(),
          'emoji': emoji,
          'doodle_data':
              doodleStrokes == null ? null : {'strokes': doodleStrokes},
        })
        .select()
        .single();

    if (voiceNote != null) {
      final vPath = '$gid/$uid/$id.m4a';
      await _sb.storage.from('voice-notes').upload(vPath, voiceNote,
          fileOptions: const FileOptions(contentType: 'audio/mp4'));
      await _sb.from('voice_notes').insert({
        'zap_id': zapRow['id'],
        'storage_url': vPath,
        'duration_seconds': voiceDurationSeconds,
      });
    }

    ref.invalidate(zapsProvider);
  }

  Future<void> react(String zapId, String emoji) async {
    final uid = ref.read(currentUserIdProvider)!;
    await _sb.from('zap_reactions').upsert({
      'zap_id': zapId,
      'user_id': uid,
      'emoji': emoji,
    }, onConflict: 'zap_id,user_id');
    ref.invalidate(zapsProvider);
  }

  Future<void> markSeen(String zapId) async {
    await _sb.from('zaps').update({'seen': true}).eq('id', zapId);
  }
}

final zapControllerProvider = Provider((ref) => ZapController(ref));

/// Fixed reaction palette (plan: 8 emojis, no text).
const zapReactionEmojis = ['❤️', '😂', '😮', '🥺', '🔥', '👏', '⚡', '💀'];
