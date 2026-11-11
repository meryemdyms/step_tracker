
import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../repositories/user_profile_repository.dart';
import '../repositories/walking_repository.dart';
import '../services/activity_calculation_service.dart';
import '../services/step_service.dart';

enum StatisticsPeriod {
  weekly,
  monthly,
}

class _DailyStepData {
  final DateTime date;
  final int? steps;

  const _DailyStepData({
    required this.date,
    required this.steps,
  });
}

class StatisticsScreen extends StatefulWidget {
  final WalkingRepository repository;
  final UserProfileRepository profileRepository;

  const StatisticsScreen({
    super.key,
    required this.repository,
    required this.profileRepository,
  });

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  final StepService _stepService = StepService();

  final ActivityCalculationService _calculations =
      const ActivityCalculationService();

  StatisticsPeriod _period = StatisticsPeriod.weekly;
  DateTime _selectedDate = DateTime.now();

  List<_DailyStepData> _dailyData = [];
  List<WalkingSession> _completedWalks = [];

  double? _heightCm;
  double? _weightKg;
  int _dailyStepGoal = 10000;

  bool _loading = true;
  String? _errorMessage;

  // Eski isteğin yeni seçimin sonuçlarını ezmesini önler.
  int _loadVersion = 0;

  static const Color _coral = Color(0xFFEE846F);
  static const Color _blue = Color(0xFF65A7C1);

  static const List<String> _weekLabels = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadStatistics();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadStatistics();
    }
  }

  DateTime _dayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get _weekStart {
    final day = _dayStart(_selectedDate);

    return day.subtract(
      Duration(days: day.weekday - 1),
    );
  }

  DateTime get _periodStart {
    switch (_period) {
      case StatisticsPeriod.weekly:
        return _weekStart;

      case StatisticsPeriod.monthly:
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
        );
    }
  }

  DateTime get _periodEndExclusive {
    switch (_period) {
      case StatisticsPeriod.weekly:
        return DateTime(
          _weekStart.year,
          _weekStart.month,
          _weekStart.day + 7,
        );

      case StatisticsPeriod.monthly:
        return DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
        );
    }
  }

  List<DateTime> _selectedDays() {
    final start = _periodStart;
    final end = _periodEndExclusive;

    final days = <DateTime>[];

    for (
      var day = start;
      day.isBefore(end);
      day = DateTime(
        day.year,
        day.month,
        day.day + 1,
      )
    ) {
      days.add(day);
    }

    return days;
  }

  Future<void> _loadStatistics() async {
    final version = ++_loadVersion;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final profile =
          await widget.profileRepository.getProfile();

      final walks =
          await widget.repository.getCompletedWalks();

      final today = _dayStart(DateTime.now());
      final days = _selectedDays();

      final results = <_DailyStepData>[];

      // Health sorgularını yedişerli gruplarla yap.
      for (var i = 0; i < days.length; i += 7) {
        final batch = days.skip(i).take(7).toList();

        final values = await Future.wait(
          batch.map((day) async {
            // Gelecek günler için veri sorgulama.
            if (day.isAfter(today)) {
              return _DailyStepData(
                date: day,
                steps: null,
              );
            }

            final steps =
                await _stepService.getStepsForDate(day);

            return _DailyStepData(
              date: day,
              steps: steps,
            );
          }),
        );

        results.addAll(values);
      }

      if (!mounted || version != _loadVersion) {
        return;
      }

      setState(() {
        _dailyData = results;
        _completedWalks = walks;

        _heightCm = profile?.heightCm;
        _weightKg = profile?.weightKg;

        _dailyStepGoal =
            profile?.dailyStepGoal ?? 10000;

        _loading = false;
      });
    } catch (e) {
      if (!mounted || version != _loadVersion) {
        return;
      }

      setState(() {
        _errorMessage =
            'İstatistikler yüklenemedi: $e';

        _loading = false;
      });
    }
  }

  void _changePeriod(StatisticsPeriod period) {
    if (_period == period) return;

    setState(() {
      _period = period;
      _selectedDate = DateTime.now();
    });

    _loadStatistics();
  }

  void _changeDate(int direction) {
    final current = _selectedDate;

    DateTime next;

    switch (_period) {
      case StatisticsPeriod.weekly:
        next = DateTime(
          current.year,
          current.month,
          current.day + direction * 7,
        );
        break;

      case StatisticsPeriod.monthly:
        next = DateTime(
          current.year,
          current.month + direction,
        );
        break;
    }

    if (next.isAfter(DateTime.now()) && direction > 0) {
      return;
    }

    setState(() {
      _selectedDate = next;
    });

    _loadStatistics();
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
      case StatisticsPeriod.weekly:
        final end = DateTime(
          _weekStart.year,
          _weekStart.month,
          _weekStart.day + 6,
        );

        if (_weekStart.month == end.month &&
            _weekStart.year == end.year) {
          return '${_weekStart.day}–${end.day} '
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

  String _formatNumber(num number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  String _formatDistance(double distance) {
    return distance
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  List<int> get _knownSteps {
    return _dailyData
        .where((day) => day.steps != null)
        .map((day) => day.steps!)
        .toList();
  }

  int? get _totalSteps {
    final steps = _knownSteps;

    if (steps.isEmpty) return null;

    return steps.fold<int>(
      0,
      (sum, value) => sum + value,
    );
  }

  int? get _averageSteps {
    final steps = _knownSteps;

    if (steps.isEmpty) return null;

    return _totalSteps! ~/ steps.length;
  }

  double? get _totalDistanceKm {
    if (_totalSteps == null ||
        _heightCm == null ||
        _heightCm! <= 0) {
      return null;
    }

    return _calculations.estimatedDistanceKm(
      steps: _totalSteps!,
      heightCm: _heightCm!,
    );
  }

  int? get _totalCalories {
    if (_totalDistanceKm == null ||
        _weightKg == null ||
        _weightKg! <= 0) {
      return null;
    }

    return _calculations.estimatedActiveCalories(
      distanceKm: _totalDistanceKm!,
      weightKg: _weightKg!,
    ).round();
  }

  int get _goalDays {
    return _dailyData.where((day) {
      final steps = day.steps;

      return steps != null &&
          steps >= _dailyStepGoal;
    }).length;
  }

  int get _walkCount {
    final start = _periodStart;
    final end = _periodEndExclusive;

    return _completedWalks.where((walk) {
      return !walk.startedAt.isBefore(start) &&
          walk.startedAt.isBefore(end);
    }).length;
  }

  List<String> get _chartLabels {
    switch (_period) {
      case StatisticsPeriod.weekly:
        return _weekLabels;

      case StatisticsPeriod.monthly:
        return _dailyData.map((day) {
          final number = day.date.day;

          return number == 1 || number % 5 == 0
              ? '$number'
              : '';
        }).toList();
    }
  }

  Widget _buildPeriodSelector() {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 43,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHighest
            : const Color(0xFFEAF1F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
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
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => _changePeriod(value),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _blue
                : Colors.transparent,
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
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeDate(-1),
          icon: const Icon(
            Icons.chevron_left,
            size: 25,
          ),
        ),

        Flexible(
          child: Text(
            _dateLabel(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
    if (_dailyData.isEmpty) {
      return const SizedBox(
        height: 185,
        child: Center(
          child: Text(
            'Grafik verisi bulunamadı.',
          ),
        ),
      );
    }

    final maxSteps = _dailyData
        .map((day) => day.steps ?? 0)
        .fold<int>(
          0,
          (maximum, value) =>
              value > maximum ? value : maximum,
        );

    final labels = _chartLabels;

    return SizedBox(
      height: 185,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: List.generate(
          _dailyData.length,
          (index) {
            final value =
                _dailyData[index].steps;

            final fraction =
                value == null || maxSteps == 0
                    ? 0.0
                    : value / maxSteps;

            final isMonthly =
                _period == StatisticsPeriod.monthly;

            return Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (context, constraints) {
                        return Align(
                          alignment:
                              Alignment.bottomCenter,
                          child: Container(
                            width: isMonthly ? 7 : 19,
                            height:
                                constraints.maxHeight *
                                    fraction,
                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                begin:
                                    Alignment.topCenter,
                                end:
                                    Alignment.bottomCenter,
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
                          fontSize:
                              isMonthly ? 9 : 11,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
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
    final isDark =
        theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 113,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17),
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
              style: theme.textTheme.labelSmall
                  ?.copyWith(
                fontSize: 10,
              ),
            ),

            const Spacer(),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final totalSteps = _totalSteps;
    final averageSteps = _averageSteps;
    final totalCalories = _totalCalories;
    final totalDistance = _totalDistanceKm;

    final knownDays = _knownSteps.length;

    final totalDays = _dailyData
        .where(
          (day) => !day.date.isAfter(
            _dayStart(DateTime.now()),
          ),
        )
        .length;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight > 44
                        ? constraints.maxHeight - 44
                        : 0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'İstatistikler',
                    style: theme
                        .textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _buildPeriodSelector(),

                  const SizedBox(height: 10),

                  _buildDateSelector(),

                  const SizedBox(height: 5),

                  Divider(
                    color:
                        colors.outlineVariant,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    totalSteps == null
                        ? '—'
                        : _formatNumber(
                            totalSteps,
                          ),
                    textAlign:
                        TextAlign.center,
                    style: theme
                        .textTheme.headlineLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 34,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Toplam Adım',
                    textAlign:
                        TextAlign.center,
                    style: theme
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Divider(
                    color:
                        colors.outlineVariant,
                  ),

                  const SizedBox(height: 10),

                  _buildBarChart(),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _summaryCard(
                        icon: Icons
                            .directions_walk_rounded,
                        label: 'Ort. Adım',
                        value:
                            averageSteps == null
                                ? '—'
                                : _formatNumber(
                                    averageSteps,
                                  ),
                        iconColor: _coral,
                      ),

                      const SizedBox(
                        width: 9,
                      ),

                      _summaryCard(
                        icon: Icons
                            .local_fire_department_rounded,
                        label: 'Kalori',
                        value:
                            totalCalories == null
                                ? '—'
                                : '$totalCalories',
                        iconColor: _coral,
                      ),

                      const SizedBox(
                        width: 9,
                      ),

                      _summaryCard(
                        icon: Icons
                            .location_on_rounded,
                        label: 'Mesafe',
                        value:
                            totalDistance == null
                                ? '—'
                                : '${_formatDistance(totalDistance)} km',
                        iconColor: _blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hedefe ulaşılan gün',
                        style: theme
                            .textTheme.bodyMedium,
                      ),
                      Text(
                        '$_goalDays gün',
                        style: theme
                            .textTheme.bodyMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tamamlanan yürüyüş',
                        style: theme
                            .textTheme.bodyMedium,
                      ),
                      Text(
                        '$_walkCount',
                        style: theme
                            .textTheme.bodyMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    knownDays == 0
                        ? 'Bu dönem için sağlık verisi okunamadı.'
                        : knownDays < totalDays
                            ? '$knownDays/$totalDays günün sağlık verisi '
                                'okunabildi. Toplamlar kısmi olabilir.'
                            : 'Mesafe ve kalori, Health adımlarından '
                                'hesaplanan tahmini değerlerdir.',
                    textAlign:
                        TextAlign.center,
                    style: theme
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: colors
                          .onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _loadVersion++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.all(
                            24,
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                        FilledButton(
                          onPressed:
                              _loadStatistics,
                          child: const Text(
                            'Tekrar Dene',
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }
}
