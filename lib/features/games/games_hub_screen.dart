import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'game_provider.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Games 🎮')),
        body: const GamesHubBody(),
      );
}

class GamesHubBody extends ConsumerWidget {
  const GamesHubBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gamesRealtimeProvider);
    final open = ref.watch(openGamesProvider);
    final leaderboard = ref.watch(leaderboardProvider);
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final myId = ref.watch(currentUserIdProvider);

    String roleOf(String? uid) {
      for (final m in members) {
        if (m.userId == uid) return m.roleName;
      }
      return 'someone';
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(openGamesProvider);
        ref.invalidate(leaderboardProvider);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text('Start a game',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              for (final t in GameType.values)
                SectionCard(
                  onTap: () async {
                    try {
                      final s =
                          await ref.read(gameControllerProvider).create(t);
                      if (context.mounted) {
                        context.push('/games/session/${s.id}');
                      }
                    } catch (e) {
                      if (context.mounted) showSnack(context, 'Failed: $e');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 6),
                      Text(t.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          t.defaultMaxPlayers > 2
                              ? 'up to ${t.defaultMaxPlayers}'
                              : '2 players',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
            ],
          ),
          // ---- open lobbies ----
          open.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (games) => games.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Text('Live now',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      for (final g in games)
                        SectionCard(
                          onTap: () async {
                            if (g.createdBy != myId && g.status == 'lobby') {
                              try {
                                await ref
                                    .read(gameControllerProvider)
                                    .join(g.id);
                              } catch (_) {}
                            }
                            if (context.mounted) {
                              context.push('/games/session/${g.id}');
                            }
                          },
                          child: Row(
                            children: [
                              Text(g.gameType.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g.gameType.label,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        '${g.status == 'lobby' ? 'Lobby' : 'Playing'} · host: ${roleOf(g.createdBy)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white
                                                .withValues(alpha: 0.5))),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(g.status == 'lobby'
                                    ? 'Join'
                                    : 'Watch'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          // ---- leaderboard ----
          leaderboard.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (rows) => rows.isEmpty
                ? const SizedBox.shrink()
                : SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🏆 Leaderboard',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        for (var i = 0; i < rows.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Text(['🥇', '🥈', '🥉'].length > i
                                    ? ['🥇', '🥈', '🥉'][i]
                                    : '  '),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(roleOf(rows[i]['user_id']))),
                                Text('${rows[i]['wins']} wins',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
