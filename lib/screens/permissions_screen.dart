
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/onboarding_status_service.dart';
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() =>
      _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _activityGranted = false;
  bool _locationGranted = false;
  bool _isLoading = false;

  bool get _isAndroid =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  bool get _isIOS =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS;

  final OnboardingStatusService _onboardingStatus =
    OnboardingStatusService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!_isAndroid && !_isIOS) return;

    try {
      final location = await Geolocator.checkPermission();

      bool activityGranted = false;

      if (_isAndroid) {
        final status =
            await Permission.activityRecognition.status;

        activityGranted = status.isGranted;
      }

      if (!mounted) return;

      setState(() {
        _locationGranted =
            location == LocationPermission.whileInUse ||
            location == LocationPermission.always;

        _activityGranted = activityGranted;
      });
    } catch (_) {
      _showMessage('İzin durumları kontrol edilemedi.');
    }
  }

  Future<void> _requestActivityPermission() async {
    if (!_isAndroid) return;

    try {
      final status =
          await Permission.activityRecognition.request();

      if (!mounted) return;

      setState(() {
        _activityGranted = status.isGranted;
      });

      if (status.isPermanentlyDenied) {
        _showMessage(
          'Aktivite iznini cihaz ayarlarından açabilirsin.',
        );
      }
    } catch (_) {
      _showMessage('Aktivite izni istenemedi.');
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!_isAndroid && !_isIOS) return;

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage('Telefonunun konum servisi kapalı.');
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Konum izni cihaz ayarlarından açılmalı.',
        );

        await Geolocator.openAppSettings();
        return;
      }

      setState(() {
        _locationGranted =
            permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      });
    } catch (_) {
      _showMessage('Konum izni istenemedi.');
    }
  }

  
Future<void> _requestAndContinue() async {
  if (_isLoading) return;

  setState(() => _isLoading = true);

  try {
    // Android aktivite izni
    if (_isAndroid && !_activityGranted) {
      await _requestActivityPermission();
    }

    // Android ve iOS konum izni
    if ((_isAndroid || _isIOS) && !_locationGranted) {
      await _requestLocationPermission();
    }

    if (!mounted) return;

    // Kullanıcı izin vermese bile kurulum aşamasını
    // tamamlamayı seçebilir.
    await _onboardingStatus.markCompleted();

    if (!mounted) return;

    // Artık sonraki açılışlarda Splash,
    // kullanıcıyı doğrudan ana sayfaya yönlendirebilir.
    context.go('/home');
  } catch (_) {
    if (!mounted) return;

    _showMessage(
      'Kurulum durumu kaydedilemedi. Tekrar deneyin.',
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required VoidCallback onTap,
    bool pendingIntegration = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surface : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 19,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF7698A8)
                          .withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 29,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                granted
                    ? Icons.check_circle_rounded
                    : pendingIntegration
                        ? Icons.info_outline_rounded
                        : Icons.circle_outlined,
                color: granted
                    ? colors.secondary
                    : colors.onSurfaceVariant,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? colors.surface : const Color(0xFFF9FBFD),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Text(
                        'Gerekli İzinler',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Adım ve yürüyüş verilerini takip '
                        'edebilmemiz için izinlerine '
                        'ihtiyacımız var.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 34),

                      _permissionCard(
                        icon: Icons.favorite_rounded,
                        title: 'Aktivite Verileri',
                        description:
                            'Günlük adım ve hareket verilerini '
                            'okumamızı sağlar.',
                        granted: _activityGranted,
                        pendingIntegration: !_isAndroid,
                        onTap: () {
                          if (_isAndroid) {
                            _requestActivityPermission();
                          } else {
                            _showMessage(
                              'iOS hareket verisi izni, '
                              'adım takip servisine '
                              'bağlandığında istenecek.',
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      _permissionCard(
                        icon: Icons.location_on_rounded,
                        title: 'Konum',
                        description:
                            'Yürüyüş sırasında rotanı '
                            'kaydetmemizi sağlar.',
                        granted: _locationGranted,
                        onTap: _requestLocationPermission,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed:
                        _isLoading ? null : _requestAndContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text(
                            'İzin Ver ve Devam Et',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
