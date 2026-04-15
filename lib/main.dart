import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/firebase_config.dart';
import 'core/config/hive_config.dart';
import 'core/router/router.dart';
import 'core/theme/theme.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/offline_banner.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await HiveConfig.initialize();

  // Initialize Firebase (also sets up FlutterError.onError and
  // PlatformDispatcher.instance.onError for Crashlytics)
  await FirebaseConfig.initialize();

  AppLogger.info('App started');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Q-ez Quiz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
