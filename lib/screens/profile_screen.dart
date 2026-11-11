
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/user_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfileRepository repository;

  const ProfileScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _dailyStepGoal;
  bool _isLoading = true;

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
        _dailyStepGoal = profile?.dailyStepGoal;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Profil bilgileri yüklenemedi.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Icon(
        icon,
        color: colors.secondary,
        size: 26,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final goalText = _isLoading
        ? 'Yükleniyor...'
        : _dailyStepGoal == null
            ? 'Henüz belirlenmedi'
            : 'Günlük hedefin: $_dailyStepGoal';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Profil',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colors.secondary,
                child: Icon(
                  Icons.person_rounded,
                  color: colors.onSecondary,
                  size: 56,
                ),
              ),
            ),

            const SizedBox(height: 32),
Card(
  color: theme.brightness == Brightness.light
      ? Colors.white
      : colors.surfaceContainerLow,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
              child: Column(
                children: [
                  _profileOption(
                    icon: Icons.person_outline_rounded,
                    title: 'Kişisel Bilgiler',
                    subtitle: 'Boy, kilo ve diğer bilgiler',
                    onTap: () async {
  final updated = await context.push<bool>('/edit-profile');

  if (!mounted) return;

  if (updated == true) {
    await _loadProfile();
  }
},
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _profileOption(
                    icon: Icons.track_changes_rounded,
                    title: 'Adım Hedefi',
                    subtitle: goalText,
                   onTap: () async {
  final updated = await context.push<bool>('/step-goal');

  if (!mounted) return;

  if (updated == true) {
    await _loadProfile();
  }
},
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _profileOption(
                    icon: Icons.notifications_none_rounded,
                    title: 'Bildirimler',
                    subtitle: 'Hedef ve hatırlatmalar',
                    onTap: () {
                      _showMessage(
                        'Bildirim ayarları henüz hazırlanmadı.',
                      );
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _profileOption(
                    icon: Icons.sync_rounded,
                    title: 'Veri Senkronizasyonu',
                    subtitle: 'Health Connect / Apple Health',
                    onTap: () {
                      _showMessage(
                        'Sağlık verisi bağlantısı henüz hazırlanmadı.',
                      );
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _profileOption(
                    icon: Icons.brightness_6_outlined,
                    title: 'Tema',
                    subtitle: 'Sistem ayarı',
                  onTap: () {
  context.push('/theme-settings');
},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
