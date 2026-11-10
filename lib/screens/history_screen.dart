
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';
import '../repositories/walking_repository.dart';

class HistoryScreen extends StatefulWidget {
  final WalkingRepository repository;

  const HistoryScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<WalkingSession>> _walksFuture;

  @override
  void initState() {
    super.initState();
    _refreshWalks();
  }

  void _refreshWalks() {
    _walksFuture = widget.repository.getCompletedWalks();
  }

  Future<void> _reloadWalks() async {
    setState(_refreshWalks);
    await _walksFuture;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan',
      'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
      'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];

    return '${localDate.day} '
        '${months[localDate.month - 1]} '
        '${localDate.year}';
  }

  String _formatTime(DateTime date) {
    final localDate = date.toLocal();

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours sa $minutes dk';
    }

    if (minutes == 0) {
      return '$seconds sn';
    }

    return '$minutes dk';
  }

  Widget _buildWalkingCard(WalkingSession walk) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final distanceKm =
        (walk.distanceMeters / 1000).toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/walking-summary/${walk.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    child: Icon(
                      Icons.directions_walk,
                      color: colors.onSecondaryContainer,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(walk.startedAt),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(walk.startedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right),
                ],
              ),

              const Divider(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text('$distanceKm km'),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: colors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(walk.durationSeconds),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aktivite kayıtların',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Yürüyüş Geçmişi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: FutureBuilder<List<WalkingSession>>(
                  future: _walksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState !=
                        ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Yürüyüş geçmişi yüklenemedi.',
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _reloadWalks,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      );
                    }

                    final walks = snapshot.data ?? [];

                    if (walks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Henüz tamamlanmış yürüyüşün yok.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reloadWalks,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        itemCount: walks.length,
                        itemBuilder: (context, index) {
                          return _buildWalkingCard(walks[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
