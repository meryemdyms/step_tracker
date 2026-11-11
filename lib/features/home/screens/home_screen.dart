
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../profile/repositories/user_profile_repository.dart';
import '../../../core/services/step_service.dart';
import '../../../core/services/activity_calculation_service.dart';
import '../../../core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const HomeScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  int _dailyStepGoal = 10000;

  final StepService _stepService = StepService();

  final ActivityCalculationService _calculations =
      const ActivityCalculationService();

  Timer? _stepsRefreshTimer;

  int? _todaySteps;
  double? _heightCm;
  double? _weightKg;

  bool _isLoadingSteps = true;
  bool _isLoading = true;
  bool _isRefreshingSteps = false;

  String? _errorMessage;

  static const _coral = Color(0xFFEE846F);
  static const _blue = Color(0xFF65A7C1);

  double? get _distanceKm {
    if (_todaySteps == null || _heightCm == null) {
      return null;
    }

    return _calculations.estimatedDistanceKm(
      steps: _todaySteps!,
      heightCm: _heightCm!,
    );
  }

  int? get _calories {
    if (_distanceKm == null || _weightKg == null) {
      return null;
    }

    return _calculations.estimatedActiveCalories(
      distanceKm: _distanceKm!,
      weightKg: _weightKg!,
    ).round();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _refreshAll();

    // Uygulama açıkken Health verilerini düzenli yenile.
    _stepsRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _loadSteps(),
    );
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  // Önce güncel hedefi, sonra Health adımlarını okuyoruz.
  Future<void> _refreshAll() async {
    await _loadProfile();

    if (!mounted) return;

    await _loadSteps();
  }

  Future<void> _loadSteps() async {
    if (_isRefreshingSteps) return;

    _isRefreshingSteps = true;

    try {
      final steps = await _stepService.getTodaySteps();

      if (!mounted) return;

      setState(() {
        _todaySteps = steps;
        _isLoadingSteps = false;
      });

      // Sağlık verileri gerçekten okunmuşsa
      // günlük hedef bildirimi kontrol edilir.
      if (steps != null && _dailyStepGoal > 0) {
        unawaited(
          NotificationService.instance.checkDailyStepGoal(
            steps: steps,
            goal: _dailyStepGoal,
          ),
        );
      }
    } catch (e) {
      debugPrint('Günlük adım okuma hatası: $e');

      if (!mounted) return;

      setState(() {
        _todaySteps = null;
        _isLoadingSteps = false;
      });
    } finally {
      _isRefreshingSteps = false;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
          await widget.repository.getProfile();

      if (!mounted) return;

      setState(() {
        _dailyStepGoal =
            profile?.dailyStepGoal ?? 10000;

        _heightCm =
            (profile?.heightCm as num?)?.toDouble();

        _weightKg =
            (profile?.weightKg as num?)?.toDouble();

        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Kullanıcı bilgileri okuma hatası: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Kullanıcı bilgileri yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _stepsRefreshTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  String _todayText() {
    final today = DateTime.now();

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

    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    return '${today.day} ${months[today.month - 1]} '
        '${weekdays[today.weekday - 1]}';
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugün',
              style:
                  theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _todayText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        // Bildirim ayarları ekranına yönlendirir.
        IconButton(
          onPressed: () {
            context.push('/notification-settings');
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 27,
          ),
          tooltip: 'Bildirim Ayarları',
        ),
      ],
    );
  }

  Widget _buildStepChart() {
    // Gerçek saatlik adım verisi gelene kadar
    // dekoratif grafik önizlemesi.
    const heights = [
      0.12,
      0.18,
      0.16,
      0.25,
      0.34,
      0.22,
      0.55,
      0.29,
      0.41,
      0.61,
      0.35,
      0.73,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((height) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            child: FractionallySizedBox(
              heightFactor: height,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.50,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsCard(double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        19,
        18,
        19,
        17,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF39581),
            Color(0xFFEE846F),
          ],
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adımlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.directions_walk_rounded,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _isLoadingSteps
                    ? '...'
                    : _todaySteps == null
                        ? '—'
                        : _formatNumber(_todaySteps!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),

              const SizedBox(width: 6),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  '/ ${_formatNumber(_dailyStepGoal)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: _isLoadingSteps
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : _todaySteps == null
                    ? const Center(
                        child: Text(
                          'Adım verileri okunamadı',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : _buildStepChart(),
          ),

          const SizedBox(height: 4),

          Text(
            _todaySteps == null
                ? 'Adım verileri henüz okunamadı'
                : 'Saatlik grafik önizlemesi',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.75,
              ),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required double height,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.045,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 25,
                color: iconColor,
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  label,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      color: theme
                          .colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStart(double buttonHeight) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Başlat',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Material(
          color: isDark
              ? theme.colorScheme.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: () => context.push('/walking-map'),
            child: Container(
              height: buttonHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(19),
                border: Border.all(
                  color: _blue.withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        _coral.withValues(
                      alpha: 0.10,
                    ),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      color: _coral,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Yürüyüşe Başla',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 37),
                ],
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
    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF7FAFC),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Text(_errorMessage!),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight =
                          constraints.maxHeight;

                      // Küçük ekranlarda referans ölçüler.
                      // Büyük ekranlarda oranlı büyüme.
                      final extra = math.max(
                        0.0,
                        availableHeight - 560,
                      );

                      final stepHeight =
                          190.0 +
                          math.min(extra * 0.38, 90.0);

                      final infoHeight =
                          105.0 +
                          math.min(extra * 0.16, 35.0);

                      final quickButtonHeight =
                          74.0 +
                          math.min(extra * 0.10, 18.0);

                      final headerGap =
                          22.0 +
                          math.min(extra * 0.06, 12.0);

                      final infoGap =
                          15.0 +
                          math.min(extra * 0.04, 8.0);

                      final quickGap =
                          27.0 +
                          math.min(extra * 0.16, 35.0);

                      return RefreshIndicator(
                        onRefresh: _refreshAll,
                        child: SingleChildScrollView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            18,
                            20,
                            22,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: math.max(
                                0,
                                availableHeight - 40,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),

                                SizedBox(
                                  height: headerGap,
                                ),

                                _buildStepsCard(
                                  stepHeight,
                                ),

                                SizedBox(
                                  height: infoGap,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        height: infoHeight,
                                        icon: Icons
                                            .local_fire_department_rounded,
                                        label: 'Kalori',
                                        value: _calories
                                                ?.toString() ??
                                            '—',
                                        unit: 'kcal',
                                        iconColor: _coral,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _buildInfoCard(
                                        height: infoHeight,
                                        icon: Icons
                                            .location_on_rounded,
                                        label: 'Mesafe',
                                        value: _distanceKm
                                                ?.toStringAsFixed(1)
                                                .replaceAll('.', ',') ??
                                            '—',
                                        unit: 'km',
                                        iconColor: _blue,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: quickGap,
                                ),

                                _buildQuickStart(
                                  quickButtonHeight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}