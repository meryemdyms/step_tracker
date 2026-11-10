
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalkingScreen extends StatelessWidget {
  const WalkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktif yürüyüş',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yürüyüşe Hazır Mısın?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.directions_walk_rounded,
                    color: colors.primary,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              height: 210,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: colors.onSecondaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Yürüyüş rotan burada görünecek',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS takibi başlatıldığında',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: const [
                Expanded(
                  child: _WalkingStatCard(
                    icon: Icons.timer_outlined,
                    value: '00:00',
                    label: 'Süre',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _WalkingStatCard(
                    icon: Icons.route_outlined,
                    value: '0.00',
                    label: 'km',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _WalkingStatCard(
                    icon: Icons.directions_walk,
                    value: '0',
                    label: 'Adım',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  Icons.location_on_outlined,
                  color: colors.secondary,
                ),
                title: const Text('Konum takibi'),
                subtitle: const Text(
                  'Yürüyüş sırasında rotan kaydedilecek.',
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/walking-map');
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Yürüyüşü Başlat'),
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkingStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WalkingStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: 26,
            ),
            const SizedBox(height: 12),
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
    );
  }
}
