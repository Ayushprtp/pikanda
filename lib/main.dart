import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'core/config.dart';
import 'core/router.dart';
import 'core/services/notification_service.dart';
import 'core/theme.dart';
import 'features/groups/group_provider.dart';
import 'features/safezap/safezap_service.dart';
import 'shared/models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  await NotificationService.init();

  final safeZap = SafeZapService();
  if (safeZap.smsSupported) {
    await Workmanager()
        .initialize(safezapWorkmanagerDispatcher, isInDebugMode: false);
    if (await safeZap.isEnabled()) {
      safeZap.startSmsListener();
      await safeZap.resetWatchdog();
    }
  }

  runApp(const ProviderScope(child: PikandaApp()));
}

class PikandaApp extends ConsumerWidget {
  const PikandaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final group = ref.watch(activeGroupProvider).valueOrNull;
    final themeCfg = group?.theme ?? const GroupThemeConfig();

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(themeCfg),
      routerConfig: router,
    );
  }
}
