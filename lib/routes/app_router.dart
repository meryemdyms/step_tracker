import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';

import '../repositories/user_profile_repository.dart';
import '../repositories/walking_repository.dart';

import '../screens/main_shell.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/user_info_screen.dart';
import '../screens/permissions_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/walking_map_screen.dart';
import '../screens/walking_summary_screen.dart';

GoRouter createAppRouter(AppDatabase database) {
  final profileRepository = UserProfileRepository(database);
  final walkingRepository = WalkingRepository(database);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash ekranı
    GoRoute(
  path: '/splash',
  builder: (context, state) => SplashScreen(
    repository: profileRepository,
  ),
),

      // Onboarding ekranı
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Kullanıcı bilgileri
      GoRoute(
        path: '/user-info',
        builder: (context, state) =>
            UserInfoScreen(repository: profileRepository),
      ),

      // İzinler
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),

      // Alt navigasyonun bulunduğu ekranlar
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child, location: state.uri.path);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                HomeScreen(repository: profileRepository),
          ),

          GoRoute(
            path: '/statistics',
            builder: (context, state) =>
                StatisticsScreen(repository: walkingRepository),
          ),

          GoRoute(
            path: '/history',
            builder: (context, state) =>
                HistoryScreen(repository: walkingRepository),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                ProfileScreen(repository: profileRepository),
          ),
        ],
      ),

      // Aktif yürüyüş ekranı
      // Yürüyüş otomatik olarak bu ekranda başlatılır.
      GoRoute(
        path: '/walking-map',
        builder: (context, state) =>
            WalkingMapScreen(walkingRepository: walkingRepository),
      ),

      // Yürüyüş özeti
      GoRoute(
        path: '/walking-summary/:sessionId',
        builder: (context, state) {
          final sessionId = int.tryParse(
            state.pathParameters['sessionId'] ?? '',
          );

          if (sessionId == null) {
            return const _PlaceholderScreen(title: 'Geçersiz Yürüyüş Kaydı');
          }

          return WalkingSummaryScreen(
            sessionId: sessionId,
            repository: walkingRepository,
          );
        },
      ),

      // Yürüyüş detayı - henüz geliştirilecek
      GoRoute(
        path: '/walking-detail',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yürüyüş Detayı'),
      ),

      // Adım hedefi - henüz geliştirilecek
      GoRoute(
        path: '/step-goal',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Adım Hedefi'),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title ekranı hazırlanacak')),
    );
  }
}
