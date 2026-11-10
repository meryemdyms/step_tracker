import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';
import '../repositories/user_profile_repository.dart';

import '../screens/main_shell.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/user_info_screen.dart';
import '../screens/permissions_screen.dart';
import '../screens/home_screen.dart';
import '../screens/walking_screen.dart';

GoRouter createAppRouter(AppDatabase database) {
  final profileRepository = UserProfileRepository(database);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/user-info',
        builder: (context, state) =>
            UserInfoScreen(repository: profileRepository),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
GoRoute(
  path: '/home',
  builder: (context, state) => HomeScreen(
    repository: profileRepository,
  ),
),GoRoute(
  path: '/walking',
  builder: (context, state) => const WalkingScreen(),
),
          GoRoute(
            path: '/statistics',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'İstatistikler'),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Geçmiş'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Profil'),
          ),
        ],
      ),

      GoRoute(
        path: '/walking-map',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Canlı Harita'),
      ),
      GoRoute(
        path: '/walking-summary',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yürüyüş Özeti'),
      ),
      GoRoute(
        path: '/walking-detail',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yürüyüş Detayı'),
      ),
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
