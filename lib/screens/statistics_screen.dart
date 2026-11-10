
import 'package:flutter/material.dart';

import '../repositories/walking_repository.dart';

enum StatisticsPeriod { daily, weekly, monthly }

class StatisticsScreen extends StatefulWidget {
  final WalkingRepository repository;

  const StatisticsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsPeriod _period = StatisticsPeriod.weekly;
  DateTime _selectedDate = DateTime.now();

  // Yalnızca tasarımı önizlemek için örnek veriler.
  // Sensör entegrasyonunda gerçek verilerle değiştirilecek.
  static const _weeklyDemoSteps = [
    5200, 7200, 6100, 8500, 7400, 8700, 9210,
  ];

  static const _weekLabels = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz',
  ];

  DateTime get _weekStart {
    final day = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return day.subtract(
      Duration(days: day.weekday - 1),
    );
  }

  String _dateLabel() {
    switch (_period) {
      case StatisticsPeriod.daily:
        return '${_selectedDate.day}.'
            '${_selectedDate.month}.'
            '${_selectedDate.year}';

      case StatisticsPeriod.weekly:
        final end = _weekStart.add(
          const Duration(days: 6),
        );
        return '${_weekStart.day} – ${end.day} '
            '${_monthName(end.month)}';

      case StatisticsPeriod.monthly:
        return '${_monthName(_selectedDate.month)} '
            '${_selectedDate.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan',
      'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
      'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];

    return months[month - 1];
  }

  void _changeDate(int direction) {
    setState(() {
      switch (_period) {
        case StatisticsPeriod.daily:
          _selectedDate = _selectedDate.add(
            Duration(days: direction),
          );
          break;

        case StatisticsPeriod.weekly:
          _selectedDate = _selectedDate.add(
            Duration(days: direction * 7),
          );
          break;

        case StatisticsPeriod.monthly:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + direction,
            1,
          );
          break;
      }
    });
  }

  List<int> get _demoSteps {
    switch (_period) {
      case StatisticsPeriod.daily:
        return [0, 1200, 2500, 1800, 3100, 1400];

      case StatisticsPeriod.weekly:
        return _weeklyDemoSteps;

      case StatisticsPeriod.monthly:
        return [18000, 32000, 26500, 41000];
    }
  }

  List<String> get _chartLabels {
    switch (_period) {
      case StatisticsPeriod.daily:
        return ['00', '04', '08', '12', '16', '20'];

      case StatisticsPeriod.weekly:
        return _weekLabels;

      case StatisticsPeriod.monthly:
        return ['1. hf', '2. hf', '3. hf', '4. hf'];
    }
  }

  String _formatNumber(num number) {
    final text = number.toStringAsFixed(0);
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  Widget _buildBarChart() {
    final colors = Theme.of(context).colorScheme;
    final steps = _demoSteps;
    final labels = _chartLabels;

    final maxSteps = steps.reduce(
      (a, b) => a > b ? a : b,
    );

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(steps.length, (index) {
          final fraction = maxSteps == 0
              ? 0.0
              : steps[index] / maxSteps;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction == 0
                          ? 0.01
                          : fraction,
                      child: Container(
                        width: 22,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 18,
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

    final totalSteps = _demoSteps.fold<int>(
      0,
      (total, steps) => total + steps,
    );

    final averageSteps = totalSteps ~/ _demoSteps.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'İstatistikler',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            SegmentedButton<StatisticsPeriod>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: StatisticsPeriod.daily,
                  label: Text('Günlük'),
                ),
                ButtonSegment(
                  value: StatisticsPeriod.weekly,
                  label: Text('Haftalık'),
                ),
                ButtonSegment(
                  value: StatisticsPeriod.monthly,
                  label: Text('Aylık'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (selection) {
                setState(() {
                  _period = selection.first;
                  _selectedDate = DateTime.now();
                });
              },
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _dateLabel(),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const Divider(height: 32),

            Text(
              _formatNumber(totalSteps),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Toplam Adım',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            _buildBarChart(),

            const SizedBox(height: 28),

            Row(
              children: [
                _summaryCard(
                  icon: Icons.directions_walk,
                  title: 'Ort. Adım',
                  value: _formatNumber(averageSteps),
                  iconColor: colors.primary,
                ),
                const SizedBox(width: 8),
                _summaryCard(
                  icon: Icons.local_fire_department,
                  title: 'Toplam Kalori',
                  value: '—',
                  iconColor: colors.primary,
                ),
                const SizedBox(width: 8),
                _summaryCard(
                  icon: Icons.location_on,
                  title: 'Toplam Mesafe',
                  value: '—',
                  iconColor: colors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Örnek adım verileri gösteriliyor. '
              'Gerçek sensör bağlantısı henüz yapılmadı.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
