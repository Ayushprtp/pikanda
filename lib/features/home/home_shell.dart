import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/services/location_helper.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/aes_helper.dart';
import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import '../mood/mood_provider.dart';
import '../pets/pet_screen.dart';
import '../safezap/safezap_service.dart';
import '../games/games_hub_screen.dart';
import '../zap/zap_inbox.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget session upkeep: FCM token, location refresh,
    // SafeZap watchdog re-arm + group data caching.
    Future.microtask(() async {
      await NotificationService.syncToken();
      await LocationHelper.refreshAndUpload();
      final sz = ref.read(safeZapServiceProvider);
      await sz.resetWatchdog();
      final group = await ref.read(activeGroupProvider.future);
      final members = await ref.read(groupMembersProvider.future);
      if (group != null) {
        String? codeHash;
        try {
          final row = await ref
              .read(supabaseProvider)
              .from('safe_codes')
              .select('code')
              .eq('group_id', group.id)
              .maybeSingle();
          codeHash = row?['code'];
        } catch (_) {}
        await sz.cacheGroupData(
          groupId: group.id,
          aesSalt: group.aesSalt,
          memberPhones: [
            for (final m in members)
              if (m.user?.phoneNumber != null &&
                  m.userId != ref.read(currentUserIdProvider))
                m.user!.phoneNumber!
          ],
          safeCodeHash: codeHash,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _DashboardTab(),
      const ZapInboxBody(),
      const GamesHubBody(),
      const PetBody(),
      const _MoreTab(),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), label: 'Zaps'),
          NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Pet'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
    );
  }
}

// ============================ Dashboard ============================

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(activeGroupProvider).valueOrNull;
    final me = ref.watch(myMembershipProvider);
    final streak = ref.watch(myStreakProvider).valueOrNull;
    final myMoods = ref.watch(my30DayMoodsProvider).valueOrNull ?? [];
    final today = DateTime.now();
    final checkedInToday = streak?.lastCheckin != null &&
        streak!.lastCheckin!.year == today.year &&
        streak.lastCheckin!.month == today.month &&
        streak.lastCheckin!.day == today.day;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(groupControllerProvider).refreshAll();
        ref.invalidate(myStreakProvider);
        ref.invalidate(my30DayMoodsProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                const PikandaLogo(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group?.name ?? 'Pikanda',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      if (me != null)
                        Text('hey, ${me.roleName} 👋',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
                if (streak != null) StreakBadge(streak: streak.currentStreak),
                const SizedBox(width: 8),
                AuraRing(
                  colors: auraColors(myMoods),
                  child: MemberAvatar(member: me, radius: 18),
                ),
              ],
            ),
          ),
          if (group != null) _GroupLevelCard(group: group),
          SectionCard(
            color: checkedInToday
                ? null
                : Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.18),
            onTap: () => context.push('/mood'),
            child: Row(
              children: [
                Text(checkedInToday ? '✅' : '🌈',
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          checkedInToday
                              ? 'Mood logged for today'
                              : 'How are you feeling?',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                          checkedInToday
                              ? 'Come back tomorrow to keep the streak 🔥'
                              : 'Tap to check in and keep your streak',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SectionCard(
                  onTap: () => context.push('/daily'),
                  child: const Column(children: [
                    Text('📅', style: TextStyle(fontSize: 28)),
                    SizedBox(height: 6),
                    Text('Daily', style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              Expanded(
                child: SectionCard(
                  onTap: () => context.push('/vibe'),
                  child: const Column(children: [
                    Text('🎭', style: TextStyle(fontSize: 28)),
                    SizedBox(height: 6),
                    Text('Vibes', style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              Expanded(
                child: SectionCard(
                  onTap: () => context.push('/whisper'),
                  child: const Column(children: [
                    Text('🤍', style: TextStyle(fontSize: 28)),
                    SizedBox(height: 6),
                    Text('Whisper',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
          const _PokeRow(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GroupLevelCard extends StatelessWidget {
  final Group group;
  const _GroupLevelCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🏆 Level ${group.level} — ${group.levelName}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${group.xp} XP',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: group.levelProgress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}

/// Quick-poke row: one button per member.
class _PokeRow extends ConsumerWidget {
  const _PokeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final myId = ref.watch(currentUserIdProvider);
    final others = members.where((m) => m.userId != myId).toList();
    if (others.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡ Poke someone',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in others)
                ActionChip(
                  avatar: MemberAvatar(member: m, radius: 12),
                  label: Text(m.roleName),
                  onPressed: () async {
                    try {
                      await ref.read(supabaseProvider).from('pokes').insert({
                        'group_id': m.groupId,
                        'from_user': myId,
                        'to_user': m.userId,
                      });
                      if (context.mounted) {
                        showSnack(context, 'Poked ${m.roleName} ⚡');
                      }
                    } catch (e) {
                      if (context.mounted) showSnack(context, 'Poke failed');
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================ More tab ============================

class _MoreTab extends ConsumerWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final group = ref.watch(activeGroupProvider).valueOrNull;

    final items = <(String, String, String)>[
      ('📅', 'Mood Calendar', '/mood/calendar'),
      ('🔥', 'Streaks', '/streaks'),
      ('📦', 'Memory Capsules', '/capsules'),
      ('📊', 'Stats & Highlights', '/stats'),
      ('🪣', 'Bucket List', '/bucket'),
      ('⏳', 'Countdowns', '/countdowns'),
      ('🗺️', 'SafeZap Map', '/safezap'),
      if (isAdmin) ('🛠️', 'Admin Panel', '/admin'),
    ];

    return ListView(
      children: [
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.9,
          children: [
            for (final (emoji, label, route) in items)
              SectionCard(
                onTap: () => context.push(route),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
          ],
        ),
        if (group != null)
          SectionCard(
            child: Column(
              children: [
                const Text('Invite friends',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: QrImageView(data: group.inviteCode, size: 140),
                ),
                const SizedBox(height: 8),
                SelectableText(group.inviteCode,
                    style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        SectionCard(
          onTap: () async {
            await ref.read(activeGroupIdProvider.notifier).clear();
            if (context.mounted) context.go('/groups');
          },
          child: const Row(children: [
            Icon(Icons.swap_horiz),
            SizedBox(width: 10),
            Text('Switch group'),
          ]),
        ),
        SectionCard(
          onTap: () async {
            await ref.read(authControllerProvider).signOut();
            await ref.read(activeGroupIdProvider.notifier).clear();
          },
          child: const Row(children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Sign out', style: TextStyle(color: Colors.redAccent)),
          ]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
