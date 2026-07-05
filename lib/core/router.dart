import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_panel_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/auth_provider.dart';
import '../features/capsule/capsule_screens.dart';
import '../features/daily/daily_screen.dart';
import '../features/extras/bucket_list_screen.dart';
import '../features/extras/countdowns_screen.dart';
import '../features/games/game_screens.dart';
import '../features/games/games_hub_screen.dart';
import '../features/groups/group_gate_screen.dart';
import '../features/groups/group_provider.dart';
import '../features/home/home_shell.dart';
import '../features/live/live_map_screen.dart';
import '../features/mood/mood_screens.dart';
import '../features/pets/pet_screen.dart';
import '../features/safezap/safezap_map_screen.dart';
import '../features/settings/permissions_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/streaks/streak_screen.dart';
import '../features/vibe/vibe_screens.dart';
import '../features/whisper/whisper_screen.dart';
import '../features/zap/send_zap_screen.dart';

/// Rebuilt whenever auth state or the active group changes, which re-runs
/// the redirect logic below.
final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authStateProvider);
  final activeGroup = ref.watch(activeGroupIdProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = ref.read(supabaseProvider).auth.currentSession != null;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn) return onAuth ? null : '/login';
      if (onAuth) return '/';
      if (activeGroup == null && state.matchedLocation != '/groups') {
        return '/groups';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/groups', builder: (_, __) => const GroupGateScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/mood', builder: (_, __) => const MoodPickerScreen()),
      GoRoute(
          path: '/mood/calendar',
          builder: (_, __) => const MoodCalendarScreen()),
      GoRoute(path: '/zap/send', builder: (_, __) => const SendZapScreen()),
      GoRoute(path: '/daily', builder: (_, __) => const DailyScreen()),
      GoRoute(path: '/streaks', builder: (_, __) => const StreakScreen()),
      GoRoute(path: '/whisper', builder: (_, __) => const WhisperScreen()),
      GoRoute(path: '/vibe', builder: (_, __) => const VibeScreen()),
      GoRoute(path: '/capsules', builder: (_, __) => const CapsuleListScreen()),
      GoRoute(
          path: '/capsules/new',
          builder: (_, __) => const CreateCapsuleScreen()),
      GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
      GoRoute(path: '/pet', builder: (_, __) => const PetScreen()),
      GoRoute(path: '/games', builder: (_, __) => const GamesHubScreen()),
      GoRoute(
          path: '/games/session/:id',
          builder: (_, state) =>
              GameSessionScreen(sessionId: state.pathParameters['id']!)),
      GoRoute(path: '/safezap', builder: (_, __) => const SafeZapMapScreen()),
      GoRoute(path: '/live', builder: (_, __) => const LiveMapScreen()),
      GoRoute(
          path: '/permissions', builder: (_, __) => const PermissionsScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPanelScreen()),
      GoRoute(path: '/bucket', builder: (_, __) => const BucketListScreen()),
      GoRoute(
          path: '/countdowns', builder: (_, __) => const CountdownsScreen()),
    ],
  );
});
