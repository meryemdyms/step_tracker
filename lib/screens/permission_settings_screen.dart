
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/step_service.dart';

class PermissionSettingsScreen extends StatefulWidget {
  const PermissionSettingsScreen({super.key});

  @override
  State<PermissionSettingsScreen> createState() =>
      _PermissionSettingsScreenState();
}

class _PermissionSettingsScreenState
    extends State<PermissionSettingsScreen>
    with WidgetsBindingObserver {
  final StepService _stepService = StepService();

  bool _loading = true;
  bool _busy = false;

  bool _locationGranted = false;
  bool _locationServiceEnabled = false;
  bool _motionGranted = false;

  String? _error;

  bool get _isIOS =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS;

  bool get _isAndroid =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  bool get _isMobile => _isIOS || _isAndroid;

  Permission get _motionPermission =>
      _isIOS
          ? Permission.sensors
          : Permission.activityRecognition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    if (!_isMobile) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'İzin yönetimi Android ve iOS içindir.';
      });
      return;
    }

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      final location =
          await Geolocator.checkPermission();

      final motion = await _motionPermission.status;

      if (!mounted) return;

      setState(() {
        _locationServiceEnabled = serviceEnabled;
        _locationGranted =
            location == LocationPermission.always ||
            location == LocationPermission.whileInUse;
        _motionGranted = motion.isGranted;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'İzinler kontrol edilemedi: $e';
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _requestLocation() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage(
          'Konum servisleri kapalı. '
          'Telefon ayarlarından açabilirsin.',
        );
        await Geolocator.openLocationSettings();
        return;
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
    } catch (e) {
      _showMessage('Konum izni yönetilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        await _refreshPermissions();
      }
    }
  }

  Future<void> _requestMotion() async {
    if (_busy || !_isMobile) return;

    setState(() => _busy = true);

    try {
      var permission = await _motionPermission.status;

      if (permission.isPermanentlyDenied ||
          permission.isRestricted) {
        await openAppSettings();
      } else if (!permission.isGranted) {
        permission = await _motionPermission.request();

        if (permission.isPermanentlyDenied) {
          _showMessage(
            'Hareket iznini telefon ayarlarından açabilirsin.',
          );
        }
      }
    } catch (e) {
      _showMessage('Hareket izni yönetilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        await _refreshPermissions();
      }
    }
  }

  Future<void> _requestHealth() async {
    if (_busy || !_isMobile) return;

    setState(() => _busy = true);

    try {
      final requested =
          await _stepService.requestStepPermission();

      if (!mounted) return;

      if (_isIOS) {
        _showMessage(
          'Sağlık izinleri kontrol edildi. '
          'Erişimi iPhone Sağlık uygulamasından da '
          'yönetebilirsin.',
        );
      } else {
        _showMessage(
          requested
              ? 'Sağlık izni işlemi tamamlandı.'
              : 'Sağlık izni verilmedi veya '
                  'Health Connect kullanılamıyor.',
        );
      }
    } catch (e) {
      _showMessage('Sağlık izni yönetilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String description,
    required String statusText,
    required VoidCallback onPressed,
    required String buttonText,
    bool granted = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colors.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF65A7C1)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF65A7C1),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  granted
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  color: granted
                      ? const Color(0xFF65A7C1)
                      : colors.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('İzin Yönetimi'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _refreshPermissions,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshPermissions,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20, 20, 20, 30,
                    ),
                    children: [
                      Text(
                        'Uygulama İzinleri',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adım ve yürüyüş takibi için '
                        'kullanılan izinleri buradan '
                        'kontrol edebilirsin.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _permissionCard(
                        icon: Icons.location_on_outlined,
                        title: 'Konum',
                        description:
                            'Aktif yürüyüş rotasını GPS '
                            'üzerinden kaydeder.',
                        statusText: !_locationServiceEnabled
                            ? 'Konum servisleri kapalı'
                            : _locationGranted
                                ? 'İzin verildi'
                                : 'İzin verilmedi',
                        granted: _locationServiceEnabled &&
                            _locationGranted,
                        buttonText: _locationGranted &&
                                _locationServiceEnabled
                            ? 'Konum Ayarları'
                            : 'Konum İznini Yönet',
                        onPressed: () async {
                          if (_locationGranted &&
                              _locationServiceEnabled) {
                            await Geolocator.openAppSettings();
                          } else {
                            await _requestLocation();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _permissionCard(
                        icon: Icons.directions_walk_rounded,
                        title: 'Hareket ve Fitness',
                        description:
                            'Aktif yürüyüş sırasında '
                            'telefonun adım sayacını kullanır.',
                        statusText: _motionGranted
                            ? 'İzin verildi'
                            : 'İzin verilmedi',
                        granted: _motionGranted,
                        buttonText: _motionGranted
                            ? 'Telefon Ayarlarını Aç'
                            : 'Hareket İznini Yönet',
                        onPressed: _motionGranted
                            ? () async {
                                await openAppSettings();
                              }
                            : _requestMotion,
                      ),
                      const SizedBox(height: 14),
                      _permissionCard(
                        icon: Icons.favorite_border_rounded,
                        title: 'Sağlık Verileri',
                        description:
                            'Apple Health veya Health Connect '
                            'üzerinden günlük ve geçmiş '
                            'adımları okur.',
                        statusText: _isIOS
                            ? 'Okuma izni durumu iOS tarafından '
                                'kesin olarak bildirilmez'
                            : 'Erişim Health Connect '
                                'üzerinden yönetilir',
                        buttonText: 'Sağlık İzinlerini Yönet',
                        onPressed: _requestHealth,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'İzin vermediğinde de uygulamayı '
                        'kullanabilirsin. İlgili veriler '
                        'erişilemezse gösterilemeyebilir.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
