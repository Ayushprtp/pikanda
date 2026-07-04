import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

class FriendshipStats {
  final int daysSinceCreated;
  final int totalZaps;
  final int totalPokes;
  final Mood? topMood;
  final int topMoodCount;
  final int currentStreak;
  final int longestStreak;
  final List<UserBadge> myBadges;
  final List<MonthlyHighlight> highlights;
  final List<MoodEntry> thisDayLastYear;

  FriendshipStats({
    required this.daysSinceCreated,
    required this.totalZaps,
    required this.totalPokes,
    this.topMood,
    required this.topMoodCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.myBadges,
    required this.highlights,
    required this.thisDayLastYear,
  });
}

final statsProvider = FutureProvider<FriendshipStats>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  final uid = ref.watch(currentUserIdProvider);
  final group = ref.watch(activeGroupProvider).valueOrNull;
  final sb = ref.watch(supabaseProvider);
  if (gid == null || uid == null) {
    return FriendshipStats(
        daysSinceCreated: 0,
        totalZaps: 0,
        totalPokes: 0,
        topMoodCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        myBadges: [],
        highlights: [],
        thisDayLastYear: []);
  }

  final zapCount = await sb.from('zaps').count().eq('group_id', gid);
  final pokeCount = await sb.from('pokes').count().eq('group_id', gid);

  final moodRows = await sb.from('moods').select('mood').eq('group_id', gid);
  final moodCounts = <Mood, int>{};
  for (final r in (moodRows as List)) {
    final m = Mood.fromKey(r['mood']);
    moodCounts[m] = (moodCounts[m] ?? 0) + 1;
  }
  Mood? topMood;
  var topCount = 0;
  moodCounts.forEach((m, c) {
    if (c > topCount) {
      topCount = c;
      topMood = m;
    }
  });

  final streakRow = await sb
      .from('streaks')
      .select()
      .eq('group_id', gid)
      .eq('user_id', uid)
      .maybeSingle();
  final streak =
      streakRow == null ? StreakInfo.empty() : StreakInfo.fromJson(streakRow);

  final badgeRows =
      await sb.from('user_badges').select().eq('group_id', gid).eq('user_id', uid);
  final badges = (badgeRows as List)
      .map((r) => UserBadge.fromJson((r as Map).cast<String, dynamic>()))
      .toList();

  final highlightRows = await sb
      .from('monthly_highlights')
      .select()
      .eq('group_id', gid)
      .order('month', ascending: false);
  final highlights = (highlightRows as List)
      .map((r) => MonthlyHighlight.fromJson((r as Map).cast<String, dynamic>()))
      .toList();

  // This day last year
  final lastYear = DateTime.now().subtract(const Duration(days: 365));
  final dayStart =
      DateTime.utc(lastYear.year, lastYear.month, lastYear.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final tdlyRows = await sb
      .from('moods')
      .select()
      .eq('group_id', gid)
      .gte('logged_at', dayStart.toIso8601String())
      .lt('logged_at', dayEnd.toIso8601String());
  final tdly = (tdlyRows as List)
      .map((r) => MoodEntry.fromJson((r as Map).cast<String, dynamic>()))
      .toList();

  final days = group == null
      ? 0
      : DateTime.now().difference(group.createdAt).inDays;

  return FriendshipStats(
    daysSinceCreated: days,
    totalZaps: zapCount,
    totalPokes: pokeCount,
    topMood: topMood,
    topMoodCount: topCount,
    currentStreak: streak.currentStreak,
    longestStreak: streak.longestStreak,
    myBadges: badges,
    highlights: highlights,
    thisDayLastYear: tdly,
  );
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final labels = ref.watch(moodLabelsProvider).valueOrNull;
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Highlights 📊')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (s) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(statsProvider),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              SectionCard(
                child: Column(
                  children: [
                    const Text('💞', style: TextStyle(fontSize: 36)),
                    Text('${s.daysSinceCreated} days together',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.1,
                children: [
                  _StatTile('⚡', '${s.totalZaps}', 'zaps sent'),
                  _StatTile('👉', '${s.totalPokes}', 'pokes'),
                  _StatTile(
                      s.topMood?.emoji ?? '😐',
                      s.topMood?.label(labels) ?? '—',
                      'most used mood'),
                  _StatTile('🔥', '${s.currentStreak}', 'current streak'),
                ],
              ),
              // this day last year
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📅 This day, last year',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (s.thisDayLastYear.isEmpty)
                      Text('No data from a year ago (yet!)',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5)))
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final e in s.thisDayLastYear)
                            Chip(
                                label: Text(
                                    '${e.mood.emoji} ${members.firstWhere(
                                          (m) => m.userId == e.userId,
                                          orElse: () => members.isNotEmpty
                                              ? members.first
                                              : GroupMember(
                                                  id: '',
                                                  groupId: '',
                                                  userId: '',
                                                  roleName: 'someone',
                                                  isAdmin: false,
                                                  joinedAt: DateTime.now()),
                                        ).roleName}')),
                        ],
                      ),
                  ],
                ),
              ),
              // badges
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏅 Badges (${s.myBadges.length}/${BadgeDef.all.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final def in BadgeDef.all)
                          _BadgeChip(
                            def: def,
                            earned:
                                s.myBadges.any((b) => b.badgeKey == def.key),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // monthly highlights
              if (s.highlights.isNotEmpty)
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏆 Monthly Highlights',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      for (final h in s.highlights)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Text('🌟',
                              style: TextStyle(fontSize: 24)),
                          title: Text(DateFormat.yMMMM().format(h.month)),
                          subtitle: Text(h.mostActiveDay != null
                              ? 'Busiest day: ${DateFormat.MMMd().format(h.mostActiveDay!)}'
                              : 'A month to remember'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatTile(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final BadgeDef def;
  final bool earned;
  const _BadgeChip({required this.def, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${def.title}\n${def.description}',
      child: Opacity(
        opacity: earned ? 1 : 0.28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earned
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              child: Center(
                  child: Text(def.emoji, style: const TextStyle(fontSize: 26))),
            ),
            SizedBox(
                width: 64,
                child: Text(def.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 10))),
          ],
        ),
      ),
    );
  }
}
