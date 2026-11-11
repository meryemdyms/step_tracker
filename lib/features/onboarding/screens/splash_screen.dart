
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../profile/repositories/user_profile_repository.dart';
import '../services/onboarding_status_service.dart';

class SplashScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const SplashScreen({
    super.key,
    required this.repository,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingStatusService _onboardingStatus =
      OnboardingStatusService();

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    try {
      // Splash en az 2 saniye gösterilirken
      // kurulum durumu kontrol edilir.
      final results = await Future.wait<Object?>([
        Future<void>.delayed(
          const Duration(seconds: 2),
        ),
        _getInitialRoute(),
      ]);

      if (!mounted) return;

      final destination = results[1] as String;

      context.go(destination);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Açılış bilgileri kontrol edilemedi.',
          ),
        ),
      );
    }
  }

  Future<String> _getInitialRoute() async {
    // Drift veritabanındaki kullanıcı bilgilerini kontrol et.
    final profile = await widget.repository.getProfile();

    // Kullanıcı bilgileri kayıtlı değilse ilk giriş.
    if (profile == null) {
      return '/onboarding';
    }

    // Kullanıcı bilgileri kayıtlıysa
    // kurulumun tamamlanma durumunu kontrol et.
    final completed = await _onboardingStatus.isCompleted();

    if (completed) {
      // Kullanıcı daha önce kurulumu tamamlamış.
      return '/home';
    }

    // Kullanıcı bilgileri var ancak izin ekranı
    // henüz tamamlanmamış.
    return '/permissions';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                 Text(
  'StepPulse',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: colors.onSurface,
  ),
),

                  const SizedBox(height: 12),

                Text(
  'Her adımın bir başlangıç.',
  style: theme.textTheme.bodyLarge?.copyWith(
    color: colors.onSurfaceVariant,
  ),
),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _WavePainter(
                  color: colors.primary.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
