
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

class _WalkingSummaryScreenState
    extends State<WalkingSummaryScreen> {
  late final Future<({
    WalkingSession? session,
    List<RoutePoint> points,
  })> _summaryFuture;

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

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;

    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}:'
          '${twoDigits(minutes)}:'
          '${twoDigits(remaining)}';
    }

    return '${twoDigits(minutes)}:${twoDigits(remaining)}';
  }

  Widget _buildRouteMap(List<RoutePoint> routePoints) {
    final colors = Theme.of(context).colorScheme;

    if (routePoints.isEmpty) {
      return Container(
        height: 210,
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48),
              SizedBox(height: 12),
              Text('Bu yürüyüş için GPS rotası kaydedilmedi.'),
            ],
          ),
        ),
      );
    }

    final coordinates = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coordinates.first,
            initialZoom: 16,
            initialCameraFit: coordinates.length > 1
                ? CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(coordinates),
                    padding: const EdgeInsets.all(40),
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
                    color: colors.primary,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: coordinates.first,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.trip_origin,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                Marker(
                  point: coordinates.last,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on,
                    color: colors.primary,
                    size: 38,
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
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    WalkingSession session,
    List<RoutePoint> points,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final distanceKm =
        (session.distanceMeters / 1000).toStringAsFixed(2);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 76,
          color: colors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Yürüyüş Tamamlandı!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Yürüyüşünün özeti',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),

        _buildRouteMap(points),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.timer_outlined,
                value: _formatDuration(session.durationSeconds),
                label: 'Süre',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.route_outlined,
                value: '$distanceKm km',
                label: 'Mesafe',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.directions_walk,
                value: session.stepCount?.toString() ?? '—',
                label: 'Adım',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.local_fire_department_outlined,
                value: '—',
                label: 'Kalori',
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text('Ana Sayfaya Dön'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Yürüyüş bilgileri yüklenemedi: ${snapshot.error}',
                  textAlign: TextAlign.center,
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
    );
  }
}
