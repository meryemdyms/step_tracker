
import 'package:flutter/material.dart';


import '../repositories/user_profile_repository.dart';

class HomeScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const HomeScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dailyStepGoal = 10000;
  final int _todaySteps = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.repository.getProfile();

      if (!mounted) return;

      setState(() {
        _dailyStepGoal = profile?.dailyStepGoal ?? 10000;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Kullanıcı bilgileri yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progress = _dailyStepGoal > 0
        ? (_todaySteps / _dailyStepGoal).clamp(0.0, 1.0)
        : 0.0;

    final progressPercent = (progress * 100).round();

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bugünkü aktiviten',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Adım Takip',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  colors.primaryContainer,
                              child: Icon(
                                Icons.directions_walk_rounded,
                                color: colors.primary,
                                size: 30,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 220,
                                  width: 220,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 190,
                                        width: 190,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 14,
                                          strokeCap: StrokeCap.round,
                                          backgroundColor:
                                              colors.surfaceContainerHighest,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            colors.primary,
                                          ),
                                        ),
                                      ),

                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Bugünkü adımlar',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$_todaySteps',
                                            style: theme.textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '/ $_dailyStepGoal',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color:
                                                  colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'Günlük hedefin %$progressPercent'
                                  ' tamamlandı',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.route_rounded,
                                title: '0,0 km',
                                subtitle: 'Tahmini mesafe',
                                color: colors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.local_fire_department_outlined,
                                title: '0 kcal',
                                subtitle: 'Tahmini kalori',
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),

                      
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),

            const SizedBox(height: 16),

            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
