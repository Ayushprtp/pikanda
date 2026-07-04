import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// Latest active/recent vibe check for the group (with responses).
final latestVibeCheckProvider = FutureProvider<VibeCheck?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('vibe_checks')
      .select('*, vibe_check_responses(*)')
      .eq('group_id', gid)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();
  return row == null ? null : VibeCheck.fromJson(row);
});

/// Realtime refresh when responses come in or the check is revealed.
final vibeRealtimeProvider = Provider<void>((ref) {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return;
  final channel = ref
      .watch(supabaseProvider)
      .channel('vibe:$gid')
      .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vibe_checks',
          callback: (_) => ref.invalidate(latestVibeCheckProvider))
      .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vibe_check_responses',
          callback: (_) => ref.invalidate(latestVibeCheckProvider))
      .subscribe();
  ref.onDispose(() => channel.unsubscribe());
});

class VibeScreen extends ConsumerWidget {
  const VibeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(vibeRealtimeProvider);
    final vibe = ref.watch(latestVibeCheckProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final myId = ref.watch(currentUserIdProvider);
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final labels = ref.watch(moodLabelsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibes 🎭'),
        actions: [
          IconButton(
            tooltip: 'Vibe Sync',
            icon: const Icon(Icons.multitrack_audio),
            onPressed: () => _startVibeSync(context, ref),
          ),
        ],
      ),
      body: vibe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (vc) {
          final active =
              vc != null && !vc.isRevealed && vc.expiresAt.isAfter(DateTime.now());
          final iAnswered =
              vc != null && vc.responses.any((r) => r.userId == myId);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              SectionCard(
                child: Column(
                  children: [
                    const Text('🎭', style: TextStyle(fontSize: 40)),
                    const Text('Vibe Check',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      'Everyone drops their current mood.\n'
                      'Results reveal to all at once when everyone answers.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 12),
                    if (isAdmin && !active)
                      FilledButton.icon(
                        onPressed: () => _createVibeCheck(context, ref),
                        icon: const Icon(Icons.campaign),
                        label: const Text('Start a Vibe Check'),
                      ),
                  ],
                ),
              ),
              if (vc == null)
                const EmptyState(
                    emoji: '🕊️', message: 'No vibe checks yet')
              else if (active && !iAnswered)
                _RespondCard(vibeCheck: vc, labels: labels)
              else if (active && iAnswered)
                SectionCard(
                  child: Column(children: [
                    const Text('⏳', style: TextStyle(fontSize: 36)),
                    const Text('Waiting for everyone else…',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                        '${vc.responses.length}/${members.length} answered',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5))),
                  ]),
                )
              else
                _ResultCard(vibeCheck: vc, members: members, labels: labels),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createVibeCheck(BuildContext context, WidgetRef ref) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    try {
      await ref.read(supabaseProvider).from('vibe_checks').insert({
        'group_id': gid,
        'created_by': uid,
        'expires_at':
            DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
      });
      ref.invalidate(latestVibeCheckProvider);
    } catch (e) {
      if (context.mounted) showSnack(context, 'Failed: $e');
    }
  }

  Future<void> _startVibeSync(BuildContext context, WidgetRef ref) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    // Pick any happy song for the group as the sync track.
    final row = await ref.read(supabaseProvider).rpc('pick_mood_content',
        params: {'p_group': gid, 'p_mood': 'happy'});
    String? url, title;
    if (row is List && row.isNotEmpty && row.first['song_url'] != null) {
      url = row.first['song_url'];
      title = row.first['song_title'];
    }
    if (url == null) {
      if (context.mounted) {
        showSnack(context, 'Add some songs in the admin panel first 🎵');
      }
      return;
    }
    // Everyone starts 5 seconds from now, together.
    final startsAt = DateTime.now().toUtc().add(const Duration(seconds: 5));
    await ref.read(supabaseProvider).from('vibe_sync_sessions').insert({
      'group_id': gid,
      'started_by': uid,
      'song_url': url,
      'song_title': title,
      'starts_at': startsAt.toIso8601String(),
    });
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (_) => _VibeSyncCountdown(
            startsAt: startsAt.toLocal(), url: url!, title: title),
      );
    }
  }
}

class _RespondCard extends ConsumerWidget {
  final VibeCheck vibeCheck;
  final Map<String, String>? labels;
  const _RespondCard({required this.vibeCheck, this.labels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Column(
        children: [
          const Text('Drop your vibe',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final mood in Mood.values)
                GestureDetector(
                  onTap: () async {
                    try {
                      await ref
                          .read(supabaseProvider)
                          .from('vibe_check_responses')
                          .insert({
                        'vibe_check_id': vibeCheck.id,
                        'user_id': ref.read(currentUserIdProvider),
                        'mood': mood.key,
                      });
                      ref.invalidate(latestVibeCheckProvider);
                    } catch (e) {
                      if (context.mounted) showSnack(context, 'Failed: $e');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      Text(mood.label(labels),
                          style: const TextStyle(fontSize: 11)),
                    ]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final VibeCheck vibeCheck;
  final List<GroupMember> members;
  final Map<String, String>? labels;
  const _ResultCard(
      {required this.vibeCheck, required this.members, this.labels});

  @override
  Widget build(BuildContext context) {
    final counts = <Mood, int>{};
    for (final r in vibeCheck.responses) {
      counts[r.mood] = (counts[r.mood] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SectionCard(
      child: Column(
        children: [
          const Text('Today\'s group vibe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (vibeCheck.responses.isEmpty)
            const Text('Nobody answered 🤷')
          else ...[
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: [
                    for (final e in sorted)
                      PieChartSectionData(
                        value: e.value.toDouble(),
                        color: e.key.color,
                        title: e.key.emoji,
                        titleStyle: const TextStyle(fontSize: 20),
                        radius: 55,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final e in sorted)
                  Text('${e.value}× ${e.key.emoji} ${e.key.label(labels)}',
                      style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VibeSyncCountdown extends StatefulWidget {
  final DateTime startsAt;
  final String url;
  final String? title;
  const _VibeSyncCountdown(
      {required this.startsAt, required this.url, this.title});

  @override
  State<_VibeSyncCountdown> createState() => _VibeSyncCountdownState();
}

class _VibeSyncCountdownState extends State<_VibeSyncCountdown> {
  Timer? _timer;
  int _seconds = 5;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = widget.startsAt.difference(DateTime.now()).inSeconds;
      setState(() => _seconds = left);
      if (left <= 0) {
        t.cancel();
        launchUrl(Uri.parse(widget.url),
            mode: LaunchMode.externalApplication);
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎵', style: TextStyle(fontSize: 48)),
          const Text('Vibe Sync starting…',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (widget.title != null) Text(widget.title!),
          const SizedBox(height: 12),
          Text('$_seconds',
              style: const TextStyle(
                  fontSize: 56, fontWeight: FontWeight.w800)),
          const Text('🎵 You\'re all on the same beat right now'),
        ],
      ),
    );
  }
}
