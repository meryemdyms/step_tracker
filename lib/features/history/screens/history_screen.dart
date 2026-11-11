
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../walking/repositories/walking_repository.dart';

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

  static const Color _blue = Color(0xFF65A7C1);

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

    return '${localDate.day} ${months[localDate.month - 1]}';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours sa $minutes dk';
    }

    if (minutes > 0) {
      return '$minutes dk';
    }

    return '$seconds sn';
  }

  Widget _buildWalkingCard(WalkingSession walk) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final distanceKm = (walk.distanceMeters / 1000)
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF7894A5)
                      .withValues(alpha: 0.07),
                  blurRadius: 13,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            context.push('/walking-summary/${walk.id}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: _blue,
                  size: 27,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(walk.startedAt),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Yürüyüş • $distanceKm km • '
                        '${_formatDuration(walk.durationSeconds)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                ),
              ],
            ),
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
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              Icons.directions_walk_rounded,
                              size: 60,
                              color: colors.secondary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Henüz tamamlanmış yürüyüşün yok.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
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
                        padding: const EdgeInsets.only(bottom: 24),
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
