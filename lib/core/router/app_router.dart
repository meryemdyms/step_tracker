import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';
import '../../features/profile/repositories/user_profile_repository.dart';
import '../../features/walking/repositories/walking_repository.dart';

import 'main_shell.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/user_info_screen.dart';
import '../../features/onboarding/screens/permissions_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/walking/screens/walking_map_screen.dart';
import '../../features/walking/screens/walking_summary_screen.dart';
import '../../features/profile/screens/step_goal_screen.dart';
import '../../features/profile/screens/theme_settings_screen.dart';
import '../../features/profile/screens/permission_settings_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';

GoRouter createAppRouter(AppDatabase database) {
  final profileRepository = UserProfileRepository(database);
  final walkingRepository = WalkingRepository(database);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            SplashScreen(repository: profileRepository),
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
        path: '/edit-profile',
        builder: (context, state) =>
            UserInfoScreen(repository: profileRepository, isEditing: true),
      ),

      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                HomeScreen(repository: profileRepository),
          ),

          GoRoute(
            path: '/statistics',
            builder: (context, state) => StatisticsScreen(
              repository: walkingRepository,
              profileRepository: profileRepository,
            ),
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

      GoRoute(
        path: '/walking-map',
        builder: (context, state) => WalkingMapScreen(
          walkingRepository: walkingRepository,
          profileRepository: profileRepository,
        ),
      ),

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

      GoRoute(
        path: '/walking-detail',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yürüyüş Detayı'),
      ),

      GoRoute(
        path: '/step-goal',
        builder: (context, state) =>
            StepGoalScreen(repository: profileRepository),
      ),

      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/permission-settings',
        builder: (context, state) => const PermissionSettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
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
