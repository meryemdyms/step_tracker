
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
  State<WalkingMapScreen> createState() => _WalkingMapScreenState();
}

class _WalkingMapScreenState extends State<WalkingMapScreen> {
  late final WalkingController _controller;

  bool _showingError = false;

  @override
  void initState() {
    super.initState();

    _controller = WalkingController(
      LocationService(),
      widget.walkingRepository,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.startWalking();
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}:'
          '${twoDigits(minutes)}:'
          '${twoDigits(remainingSeconds)}';
    }

    return '${twoDigits(minutes)}:'
        '${twoDigits(remainingSeconds)}';
  }

  Future<void> _finishWalking() async {
    await _controller.finishWalking();

    if (!mounted) return;

    if (_controller.status == WalkingStatus.completed) {
  context.go(
  '/walking-summary/${_controller.sessionId}',
);
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

  Widget _buildMap(Color routeColor) {
    final positions = _controller.routePositions;

    if (positions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('GPS konumu bekleniyor...'),
          ],
        ),
      );
    }

    final points = positions
        .map(
          (position) => LatLng(
            position.latitude,
            position.longitude,
          ),
        )
        .toList();

    final currentPoint = points.last;

    return FlutterMap(
      options: MapOptions(
        initialCenter: currentPoint,
        initialZoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.adim_takip',
        ),

        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              color: routeColor,
              strokeWidth: 5,
            ),
          ],
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: currentPoint,
              width: 46,
              height: 46,
              child: Icon(
                Icons.location_on,
                color: routeColor,
                size: 42,
              ),
            ),
          ],
        ),

        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 18,
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 10),
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
        final busy = _controller.isBusy;

        final isActive = status == WalkingStatus.active;
        final isPaused = status == WalkingStatus.paused;
        final isIdle = status == WalkingStatus.idle;

        final distanceKm =
            (_controller.distanceMeters / 1000)
                .toStringAsFixed(2);

        return PopScope(
          canPop: isIdle || status == WalkingStatus.completed,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && !_showingError) {
              _showingError = true;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Çıkmadan önce yürüyüşü bitirmelisin.',
                      ),
                    ),
                  )
                  .closed
                  .then((_) {
                    _showingError = false;
                  });
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Yürüyüş Takibi'),
              automaticallyImplyLeading: isIdle,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: isActive
                              ? Colors.green
                              : isPaused
                                  ? Colors.orange
                                  : colors.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isActive
                              ? 'Yürüyüş devam ediyor'
                              : isPaused
                                  ? 'Yürüyüş duraklatıldı'
                                  : 'Yürüyüş hazırlanıyor',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: _buildMap(colors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _statCard(
                          icon: Icons.timer_outlined,
                          value: _formatDuration(
                            _controller.durationSeconds,
                          ),
                          label: 'Süre',
                        ),
                        _statCard(
                          icon: Icons.route_outlined,
                          value: distanceKm,
                          label: 'km',
                        ),
                        _statCard(
                          icon: Icons.directions_walk,
                          value: '—',
                          label: 'Adım',
                        ),
                      ],
                    ),

                    if (_controller.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    if (isIdle)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : _controller.startWalking,
                          child: const Text('Tekrar Dene'),
                        ),
                      ),

                    if (isActive || isPaused)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : isActive
                                      ? _controller.pauseWalking
                                      : _controller.resumeWalking,
                              icon: Icon(
                                isActive
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                isActive
                                    ? 'Duraklat'
                                    : 'Devam Et',
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  busy ? null : _finishWalking,
                              icon: const Icon(Icons.stop),
                              label: const Text('Bitir'),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
