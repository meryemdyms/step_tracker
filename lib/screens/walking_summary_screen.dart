
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../database/app_database.dart';
import '../repositories/walking_repository.dart';

class WalkingSummaryScreen extends StatefulWidget {
  final int sessionId;
  final WalkingRepository repository;

  const WalkingSummaryScreen({
    super.key,
    required this.sessionId,
    required this.repository,
  });

  @override
  State<WalkingSummaryScreen> createState() =>
      _WalkingSummaryScreenState();
}

class _WalkingSummaryScreenState extends State<WalkingSummaryScreen> {
  late final Future<({
    WalkingSession? session,
    List<RoutePoint> points,
  })> _summaryFuture;

  static const Color _coral = Color(0xFFEE846F);
  static const Color _blue = Color(0xFF65A7C1);

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<({
    WalkingSession? session,
    List<RoutePoint> points,
  })> _loadSummary() async {
    final session =
        await widget.repository.getWalkingById(widget.sessionId);

    if (session == null) {
      return (session: null, points: <RoutePoint>[]);
    }

    final points =
        await widget.repository.getRoutePoints(widget.sessionId);

    return (session: session, points: points);
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;

    return '${_twoDigits(hours)}:'
        '${_twoDigits(minutes)}:'
        '${_twoDigits(remaining)}';
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan',
      'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
      'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];

    return '${local.day} ${months[local.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();

    return '${_twoDigits(local.hour)}:'
        '${_twoDigits(local.minute)}';
  }

  String _dateRange(WalkingSession session) {
    final start = session.startedAt;
    final end = session.endedAt;

    if (end == null) {
      return '${_formatDate(start)} · ${_formatTime(start)}';
    }

    return '${_formatDate(start)} · '
        '${_formatTime(start)} – ${_formatTime(end)}';
  }

  String _averageSpeed(WalkingSession session) {
    if (session.durationSeconds <= 0 ||
        session.distanceMeters <= 0) {
      return '—';
    }

    final kilometers = session.distanceMeters / 1000;
    final hours = session.durationSeconds / 3600;
    final speed = kilometers / hours;

    return '${speed.toStringAsFixed(1).replaceAll('.', ',')} km/sa';
  }

  Widget _buildRouteMap(List<RoutePoint> points) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (points.isEmpty) {
      return Container(
        height: 185,
        decoration: BoxDecoration(
          color: isDark
              ? colors.surfaceContainerHigh
              : const Color(0xFFEAF3F8),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 42,
              color: _blue,
            ),
            const SizedBox(height: 12),
            Text(
              'Bu yürüyüş için GPS rotası kaydedilmedi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final coordinates = points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: SizedBox(
        height: 185,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coordinates.first,
            initialZoom: 16,
            initialCameraFit: coordinates.length > 1
                ? CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(coordinates),
                    padding: const EdgeInsets.all(28),
                  )
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.adim_takip',
            ),
            if (coordinates.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: coordinates,
                    color: _coral,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: coordinates.first,
                  width: 34,
                  height: 34,
                  child: const Icon(
                    Icons.trip_origin_rounded,
                    size: 23,
                    color: _coral,
                  ),
                ),
                if (coordinates.length > 1)
                  Marker(
                    point: coordinates.last,
                    width: 34,
                    height: 34,
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 30,
                      color: _coral,
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF7894A5)
                      .withValues(alpha: 0.08),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 25,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    WalkingSession session,
    List<RoutePoint> points,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final distanceKm = (session.distanceMeters / 1000)
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            children: [
              Text(
                _dateRange(session),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              _buildRouteMap(points),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.location_on_outlined,
                      value: '$distanceKm km',
                      label: 'Mesafe',
                      iconColor: _blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.timer_outlined,
                      value: _formatDuration(
                        session.durationSeconds,
                      ),
                      label: 'Süre',
                      iconColor: _blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.directions_walk_rounded,
                      value: session.stepCount == null
                          ? '—'
                          : _formatNumber(session.stepCount!),
                      label: 'Adım',
                      iconColor: _coral,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon:
                          Icons.local_fire_department_rounded,
                      value: '—',
                      label: 'Kalori',
                      iconColor: _coral,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.speed_rounded,
                      value: _averageSpeed(session),
                      label: 'Ort. Hız',
                      iconColor: _blue,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: () => context.go('/home'),
              style: FilledButton.styleFrom(
                backgroundColor: _coral,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Yürüyüş Özeti',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder(
                future: _summaryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Yürüyüş bilgileri yüklenemedi.',
                      ),
                    );
                  }

                  final data = snapshot.data;
                  final session = data?.session;

                  if (session == null) {
                    return const Center(
                      child: Text('Yürüyüş kaydı bulunamadı.'),
                    );
                  }

                  return _buildSummary(session, data!.points);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
