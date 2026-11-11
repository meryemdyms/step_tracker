import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/onboarding_status_service.dart';
import '../../../core/services/step_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final _onboardingStatus = OnboardingStatusService();
  final _stepService = StepService();
  bool _motionGranted = false;
  bool _locationGranted = false;
  bool _healthRequested = false;
  bool _isBusy = false;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isMobile => _isAndroid || _isIOS;
  Permission get _motionPermission => _isIOS ? Permission.sensors : Permission.activityRecognition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!_isMobile) return;
    try {
      final motion = await _motionPermission.status;
      final location = await Geolocator.checkPermission();
      if (!mounted) return;
      setState(() {
        _motionGranted = motion.isGranted;
        _locationGranted = location == LocationPermission.whileInUse ||
            location == LocationPermission.always;
      });
    } catch (e) {
      debugPrint('İzin kontrol hatası: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestMotion() async {
    if (!_isMobile) return;
    try {
      var status = await _motionPermission.status;
      if (!status.isGranted && !status.isPermanentlyDenied) {
        status = await _motionPermission.request();
      }
      if (!mounted) return;
      setState(() => _motionGranted = status.isGranted);
      if (status.isPermanentlyDenied) {
        _showMessage('Hareket iznini telefon ayarlarından açabilirsin.');
      }
    } catch (e) {
      debugPrint('Hareket izni hatası: $e');
      _showMessage('Hareket ve Fitness izni istenemedi.');
    }
  }

  Future<void> _requestLocation() async {
    if (!_isMobile) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Konum servisleri kapalı. Telefon ayarlarından açabilirsin.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      setState(() {
        _locationGranted = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      });
      if (permission == LocationPermission.deniedForever) {
        _showMessage('Konum iznini telefon ayarlarından açabilirsin.');
      }
    } catch (e) {
      debugPrint('Konum izni hatası: $e');
      _showMessage('Konum izni istenemedi.');
    }
  }

  Future<void> _requestHealth() async {
    if (!_isMobile) return;
    try {
      await _stepService.requestStepPermission();
      if (!mounted) return;
      // iOS HealthKit okuma izni kesin olarak sorgulanamaz.
      // Bu yalnızca isteğin yapıldığını gösterir; izin verildiğini değil.
      setState(() => _healthRequested = true);
    } catch (e) {
      debugPrint('Sağlık izni hatası: $e');
      _showMessage('Sağlık izni istenemedi.');
    }
  }

  Future<void> _requestAndContinue() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      if (_isMobile && !_motionGranted) await _requestMotion();
      if (!mounted) return;
      if (_isMobile && !_locationGranted) await _requestLocation();
      if (!mounted) return;
      if (_isMobile && !_healthRequested) await _requestHealth();
      if (!mounted) return;
      // İzin reddedilse de onboarding tamamlanabilir.
      await _onboardingStatus.markCompleted();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('Onboarding hatası: $e');
      _showMessage('Kurulum tamamlanamadı. Tekrar deneyebilirsin.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String description,
    required String statusLabel,
    required bool done,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isBusy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEE846F).withValues(alpha: 0.12),
                child: Icon(icon, color: const Color(0xFFEE846F)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(description, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(statusLabel, style: theme.textTheme.labelSmall?.copyWith(color: colors.primary)),
                  ],
                ),
              ),
              Icon(done ? Icons.check_circle_outline : Icons.chevron_right,
                  color: done ? const Color(0xFF65A7C1) : colors.onSurfaceVariant),
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 28),
                    Text('Uygulama İzinleri', textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Adımlarını ve yürüyüşlerini takip etmek için aşağıdaki izinleri kullanıyoruz. İzinler isteğe bağlıdır.',
                        textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 30),
                    _permissionCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Hareket ve Fitness',
                      description: 'Aktif yürüyüş sırasında telefonun adım sensörünü kullanır.',
                      statusLabel: _motionGranted ? 'İzin verildi' : 'İzin verilmedi',
                      done: _motionGranted,
                      onTap: _requestMotion,
                    ),
                    const SizedBox(height: 12),
                    _permissionCard(
                      icon: Icons.location_on_rounded,
                      title: 'Konum',
                      description: 'Yürüyüş rotasını ve GPS mesafesini kaydeder.',
                      statusLabel: _locationGranted ? 'İzin verildi' : 'İzin verilmedi',
                      done: _locationGranted,
                      onTap: _requestLocation,
                    ),
                    const SizedBox(height: 12),
                    _permissionCard(
                      icon: Icons.favorite_border_rounded,
                      title: 'Sağlık Verileri',
                      description: 'Apple Health veya Health Connect üzerinden günlük ve geçmiş adımları okur.',
                      statusLabel: _healthRequested ? 'İzin isteği yapıldı' : 'İzin isteği yapılmadı',
                      done: _healthRequested,
                      onTap: _requestHealth,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isBusy ? null : _requestAndContinue,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEE846F), foregroundColor: Colors.white),
                  child: _isBusy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Devam Et'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
