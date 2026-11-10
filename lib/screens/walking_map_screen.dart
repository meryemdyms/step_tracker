
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/walking_controller.dart';
import '../repositories/walking_repository.dart';
import '../services/location_service.dart';

class WalkingMapScreen extends StatefulWidget {
  final WalkingRepository walkingRepository;

  const WalkingMapScreen({
    super.key,
    required this.walkingRepository,
  });

  @override
  State<WalkingMapScreen> createState() =>
      _WalkingMapScreenState();
}

class _WalkingMapScreenState extends State<WalkingMapScreen> {
  late final WalkingController _controller;

  final PageController _pageController = PageController();

  int _pageIndex = 0;

  static const Color _coral = Color(0xFFEE846F);
  static const Color _blue = Color(0xFF65A7C1);

  @override
  void initState() {
    super.initState();

    _controller = WalkingController(
      LocationService(),
      widget.walkingRepository,
    );

    // Ana sayfadan gelindiğinde yürüyüş otomatik başlar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.startWalking();
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;

    String two(int value) =>
        value.toString().padLeft(2, '0');

    return '${two(hours)}:${two(minutes)}:${two(remaining)}';
  }

  String _distanceText() {
    return (_controller.distanceMeters / 1000)
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  String _speedText() {
    final seconds = _controller.durationSeconds;

    if (seconds == 0 ||
        _controller.routePositions.length < 2) {
      return '—';
    }

    final kilometers = _controller.distanceMeters / 1000;
    final hours = seconds / 3600;

    final speed = kilometers / hours;

    return speed.toStringAsFixed(1).replaceAll('.', ',');
  }

  // Yürüyüşü tamamla ve özet ekranına git.
  Future<void> _finishWalking() async {
    await _controller.finishWalking();

    if (!mounted) return;

    if (_controller.status == WalkingStatus.completed) {
      final sessionId = _controller.sessionId;

      if (sessionId != null) {
        context.go('/walking-summary/$sessionId');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ??
                'Yürüyüş tamamlanamadı.',
          ),
        ),
      );
    }
  }

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _coral,
            size: 29,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Kontrol butonları yalnızca yürüyüş sayfasında kullanılır.
  Widget _walkingControls() {
    final status = _controller.status;
    final busy = _controller.isBusy;

    if (status == WalkingStatus.completed) {
      return const SizedBox.shrink();
    }

    if (status == WalkingStatus.idle) {
      return FilledButton(
        onPressed: busy
            ? null
            : _controller.startWalking,
        style: FilledButton.styleFrom(
          backgroundColor: _coral,
          foregroundColor: Colors.white,
        ),
        child: Text(
          busy ? 'Hazırlanıyor...' : 'Tekrar Dene',
        ),
      );
    }

    final paused = status == WalkingStatus.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Duraklat / Devam Et
        IconButton.filled(
          onPressed: busy
              ? null
              : paused
                  ? _controller.resumeWalking
                  : _controller.pauseWalking,
          icon: Icon(
            paused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
          ),
          iconSize: 30,
          style: IconButton.styleFrom(
            backgroundColor: _coral,
            foregroundColor: Colors.white,
            fixedSize: const Size(62, 62),
          ),
        ),

        const SizedBox(width: 18),

        // Yürüyüşü bitir
        IconButton.outlined(
          onPressed: busy ? null : _finishWalking,
          icon: const Icon(Icons.stop_rounded),
          iconSize: 27,
          style: IconButton.styleFrom(
            foregroundColor: _blue,
            fixedSize: const Size(56, 56),
          ),
        ),
      ],
    );
  }

  // SAYFA 1: Yürüyüş bilgileri
  Widget _walkingDashboard() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final status = _controller.status;

    final duration = _formatDuration(
      _controller.durationSeconds,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 32,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Text(
                  duration,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 43,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  status == WalkingStatus.paused
                      ? 'Yürüyüş duraklatıldı'
                      : status == WalkingStatus.active
                          ? 'Yürüyüş devam ediyor'
                          : 'GPS hazırlanıyor',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 28),

                // Metrik kartları
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.17,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _metricCard(
                      icon: Icons.directions_walk_rounded,
                      value: '—',
                      label: 'Adım',
                    ),
                    _metricCard(
                      icon: Icons.location_on_rounded,
                      value: '${_distanceText()} km',
                      label: 'Mesafe',
                    ),
                    _metricCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '—',
                      label: 'Kalori',
                    ),
                    _metricCard(
                      icon: Icons.speed_rounded,
                      value: _speedText() == '—'
                          ? '—'
                          : '${_speedText()} km/sa',
                      label: 'Ortalama Hız',
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Kontroller SADECE bu sayfada.
                _walkingControls(),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swipe_left_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Canlı haritayı görmek için kaydır',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SAYFA 2: Canlı harita
  Widget _mapView() {
    final positions = _controller.routePositions;

    final points = positions
        .map(
          (position) => LatLng(
            position.latitude,
            position.longitude,
          ),
        )
        .toList();

    final hasLocation = points.isNotEmpty;

    // GPS gelene kadar geçici harita merkezi.
    final center = hasLocation
        ? points.last
        : const LatLng(39.0, 35.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        20,
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey(hasLocation),
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: hasLocation ? 16 : 5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/'
                            '{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.adim_takip',
                      ),

                      // Kaydedilen GPS noktalarıyla rota.
                      if (points.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: points,
                              color: _coral,
                              strokeWidth: 5,
                            ),
                          ],
                        ),

                      // Kullanıcının son bilinen GPS noktası.
                      if (hasLocation)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: points.last,
                              width: 44,
                              height: 44,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: _coral,
                              ),
                            ),
                          ],
                        ),

                      const SimpleAttributionWidget(
                        source: Text(
                          'OpenStreetMap contributors',
                        ),
                      ),
                    ],
                  ),

                  if (!hasLocation)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'GPS konumu bekleniyor...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Harita altında yalnızca metrikler bulunur.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _mapMetric(
                'Mesafe',
                '${_distanceText()} km',
              ),
              _mapMetric(
                'Süre',
                _formatDuration(
                  _controller.durationSeconds,
                ),
              ),
              _mapMetric(
                'Ort. Hız',
                _speedText() == '—'
                    ? '—'
                    : '${_speedText()} km/sa',
              ),
            ],
          ),

          // Burada Duraklat / Bitir butonu YOK.
        ],
      ),
    );
  }

  Widget _mapMetric(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final status = _controller.status;

        final canLeave =
            status == WalkingStatus.idle ||
            status == WalkingStatus.completed;

        return PopScope(
          canPop: canLeave,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                _pageIndex == 0
                    ? 'Yürüyüş'
                    : 'Yürüyüş (Canlı)',
              ),
              automaticallyImplyLeading: canLeave,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.error,
                        ),
                      ),
                    ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                      children: [
                        _walkingDashboard(),
                        _mapView(),
                      ],
                    ),
                  ),

                  // Sayfa göstergesi
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      top: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        final selected = index == _pageIndex;

                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          width: selected ? 19 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: selected
                                ? _blue
                                : colors.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
