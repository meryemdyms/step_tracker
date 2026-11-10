
import 'package:flutter/material.dart';

import '../repositories/walking_repository.dart';

enum StatisticsPeriod {
  daily,
  weekly,
  monthly,
}

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

  static const Color _coral = Color(0xFFEE846F);
  static const Color _blue = Color(0xFF65A7C1);

  // Yalnızca tasarım önizlemesi.
  // Sensör entegrasyonunda gerçek verilerle değiştirilecek.
  static const List<int> _weeklyDemoSteps = [
    5200, 7200, 6100, 8500, 7400, 8700, 9210,
  ];

  static const List<String> _weekLabels = [
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

  String _monthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return months[month - 1];
  }

  String _dateLabel() {
    switch (_period) {
      case StatisticsPeriod.daily:
        return '${_selectedDate.day} '
            '${_monthName(_selectedDate.month)} '
            '${_selectedDate.year}';

      case StatisticsPeriod.weekly:
        final end = _weekStart.add(
          const Duration(days: 6),
        );

        if (_weekStart.month == end.month) {
          return '${_weekStart.day} – ${end.day} '
              '${_monthName(end.month)}';
        }

        return '${_weekStart.day} '
            '${_monthName(_weekStart.month)} – '
            '${end.day} ${_monthName(end.month)}';

      case StatisticsPeriod.monthly:
        return '${_monthName(_selectedDate.month)} '
            '${_selectedDate.year}';
    }
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
      (_) => '.',
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 43,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _periodButton(
            'Günlük',
            StatisticsPeriod.daily,
          ),
          _periodButton(
            'Haftalık',
            StatisticsPeriod.weekly,
          ),
          _periodButton(
            'Aylık',
            StatisticsPeriod.monthly,
          ),
        ],
      ),
    );
  }

  Widget _periodButton(
    String title,
    StatisticsPeriod value,
  ) {
    final selected = _period == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _period = value;
            _selectedDate = DateTime.now();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: selected
                  ? Colors.white
                  : const Color(0xFF273640),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeDate(-1),
          icon: const Icon(
            Icons.chevron_left,
            size: 25,
          ),
        ),
        Text(
          _dateLabel(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => _changeDate(1),
          icon: const Icon(
            Icons.chevron_right,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final steps = _demoSteps;
    final labels = _chartLabels;

    final maxSteps = steps.reduce(
      (a, b) => a > b ? a : b,
    );

    return SizedBox(
      height: 185,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(steps.length, (index) {
          final fraction = maxSteps == 0
              ? 0.0
              : steps[index] / maxSteps;

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barHeight =
                          constraints.maxHeight * fraction;

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 19,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF59883),
                                _coral,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  labels[index],
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        fontSize: 11,
                      ),
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
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 113,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF7996A6)
                        .withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
            const SizedBox(height: 9),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
            ),
            const Spacer(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final steps = _demoSteps;

    final totalSteps = steps.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    final averageSteps = steps.isEmpty
        ? 0
        : totalSteps ~/ steps.length;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20, 20, 20, 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 44,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'İstatistikler',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),

                    _buildPeriodSelector(),
                    const SizedBox(height: 10),

                    _buildDateSelector(),
                    const SizedBox(height: 5),

                    Divider(
                      color: colors.outlineVariant,
                    ),
                    const SizedBox(height: 15),

                    Text(
                      _formatNumber(totalSteps),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      'Toplam Adım',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Divider(
                      color: colors.outlineVariant,
                    ),
                    const SizedBox(height: 10),

                    _buildBarChart(),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _summaryCard(
                          icon: Icons.directions_walk_rounded,
                          label: 'Ort. Adım',
                          value: _formatNumber(averageSteps),
                          iconColor: _coral,
                        ),
                        const SizedBox(width: 9),
                        _summaryCard(
                          icon:
                              Icons.local_fire_department_rounded,
                          label: 'Toplam Kalori',
                          value: '—',
                          iconColor: _coral,
                        ),
                        const SizedBox(width: 9),
                        _summaryCard(
                          icon: Icons.location_on_rounded,
                          label: 'Toplam Mesafe',
                          value: '—',
                          iconColor: _blue,
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
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
