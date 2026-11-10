
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _activityGranted = false;
  bool _locationGranted = false;
  bool _isLoading = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!_isAndroid && !_isIOS) return;

    try {
      final location = await Geolocator.checkPermission();

      bool activityGranted = false;

      if (_isAndroid) {
        final status = await Permission.activityRecognition.status;
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
    if (!_isAndroid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final status = await Permission.activityRecognition.request();

      if (!mounted) return;

      setState(() {
        _activityGranted = status.isGranted;
      });

      if (status.isPermanentlyDenied) {
        _showMessage(
          'Fiziksel aktivite iznini cihaz ayarlarından açabilirsin.',
        );
      }
    } catch (_) {
      _showMessage('Fiziksel aktivite izni istenemedi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestLocationPermission() async {
    if ((!_isAndroid && !_isIOS) || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        _showMessage('Önce cihazının konum servisini açmalısın.');
        return;
      }

      var status = await Geolocator.checkPermission();

      if (status == LocationPermission.denied) {
        status = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      setState(() {
        _locationGranted =
            status == LocationPermission.whileInUse ||
            status == LocationPermission.always;
      });

      if (status == LocationPermission.deniedForever) {
        _showMessage(
          'Konum iznini cihaz ayarlarından açabilirsin.',
        );
      }
    } catch (_) {
      _showMessage('Konum izni istenemedi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    required String status,
    required VoidCallback? onTap,
    required bool granted,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: granted
            ? Icon(Icons.check_circle, color: colors.primary)
            : TextButton(
                onPressed: onTap,
                child: Text(status),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Icon(
                Icons.shield_outlined,
                size: 72,
                color: colors.primary,
              ),

              const SizedBox(height: 24),

              Text(
                'İzinlerini Ayarla',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),

              const SizedBox(height: 12),

              Text(
                'Adımlarını ve yürüyüş rotanı takip etmek '
                'için gerekli erişimleri yönet.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 36),

              _permissionCard(
                icon: Icons.directions_walk,
                title: 'Hareket ve Aktivite',
                description: _isIOS
                    ? 'Adım verilerine erişim, adım takip '
                        'özelliğinde etkinleştirilecek.'
                    : 'Günlük adımlarını takip etmek için.',
                status: _isAndroid ? 'İzin Ver' : 'Bilgi',
                granted: _isAndroid && _activityGranted,
                onTap: _isAndroid
                    ? _requestActivityPermission
                    : () => _showMessage(
                        'Bu izin, desteklenen cihazda '
                        'adım takip servisiyle yönetilecek.',
                      ),
              ),

              const SizedBox(height: 12),

              _permissionCard(
                icon: Icons.location_on_outlined,
                title: 'Konum',
                description: 'Aktif yürüyüş rotanı kaydetmek için.',
                status: 'İzin Ver',
                granted: _locationGranted,
                onTap: _requestLocationPermission,
              ),

              const SizedBox(height: 12),

              _permissionCard(
                icon: Icons.favorite_outline,
                title: 'Sağlık Verileri',
                description: 'Apple Health veya Health Connect '
                    'üzerinden geçmiş adımlarını okumak '
                    '(isteğe bağlı).',
                status: 'Daha Sonra',
                granted: false,
                onTap: () => _showMessage(
                  'Sağlık verisi bağlantısını daha sonra ekleyeceğiz.',
                ),
              ),

              const SizedBox(height: 36),

              FilledButton(
                onPressed: _isLoading
                    ? null
                    : () => context.go('/home'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Devam Et'),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'İzinleri daha sonra ayarlardan '
                'değiştirebilirsin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
