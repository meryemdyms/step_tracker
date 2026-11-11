
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uygulama açılmadan önce kayıtlı tema tercihini yükle.
  try {
    await themeService.loadTheme();
  } catch (e) {
    debugPrint('Tema tercihi yüklenemedi: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppDatabase _database = AppDatabase();

  late final GoRouter _router = createAppRouter(_database);

  @override
  void dispose() {
    _router.dispose();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'StepPulse',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Artık sabit değil; kullanıcı tercihiyle değişir.
          themeMode: themeService.themeMode,

          routerConfig: _router,
        );
      },
    );
  }
}
