
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Adım Takip',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Her adımını takip et.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _WavePainter(
                  primaryColor: colorScheme.primary,
                  secondaryColor: colorScheme.secondary,
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
  final Color primaryColor;
  final Color secondaryColor;

  _WavePainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.35);

    final bluePath = Path()
      ..moveTo(0, size.height * 0.65)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.10,
        size.width * 0.60,
        size.height * 0.85,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(bluePath, bluePaint);

    final coralPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25);

    final coralPath = Path()
      ..moveTo(0, size.height * 0.40)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.15,
        size.width * 0.65,
        size.height * 1.10,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(coralPath, coralPaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
