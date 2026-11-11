
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

  // Dark mode renk paleti
  static const Color _darkBackground = Color(0xFF0F151B);
  static const Color _darkCard = Color(0xFF1B2630);
  static const Color _darkAccent = Color(0xFF62A8C5);
  static const Color _darkSubtitle = Color(0xFFB9B0B0);
  static const Color _darkDivider = Color(0xFF34414B);

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
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Icon(
        icon,
        color: isDark ? _darkAccent : colors.secondary,
        size: 26,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: isDark ? Colors.white : colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? _darkSubtitle
              : colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark
            ? Colors.white
            : colors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final goalText = _isLoading
        ? 'Yükleniyor...'
        : _dailyStepGoal == null
            ? 'Henüz belirlenmedi'
            : 'Günlük hedefin: $_dailyStepGoal';

    return Scaffold(
      backgroundColor:
          isDark ? _darkBackground : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Profil',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? Colors.white
                    : colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: isDark
                    ? _darkCard
                    : colors.secondary,
                child: Icon(
                  Icons.person_rounded,
                  color: isDark
                      ? _darkAccent
                      : colors.onSecondary,
                  size: 56,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Card(
              margin: EdgeInsets.zero,
              color: isDark ? _darkCard : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Kişisel Bilgiler
                  _profileOption(
                    icon: Icons.person_outline_rounded,
                    title: 'Kişisel Bilgiler',
                    subtitle: 'Boy, kilo ve diğer bilgiler',
                    onTap: () async {
                      await context.push('/edit-profile');

                      if (!mounted) return;

                      await _loadProfile();
                    },
                  ),

                  _optionDivider(isDark),

                  // Adım Hedefi
                  _profileOption(
                    icon: Icons.track_changes_rounded,
                    title: 'Adım Hedefi',
                    subtitle: goalText,
                    onTap: () async {
                      await context.push('/step-goal');

                      if (!mounted) return;

                      await _loadProfile();
                    },
                  ),

                  _optionDivider(isDark),

                  // Bildirimler
                  _profileOption(
                    icon: Icons.notifications_none_rounded,
                    title: 'Bildirimler',
                    subtitle: 'Günlük yürüyüş hatırlatmaları',
                    onTap: () {
                      context.push('/notification-settings');
                    },
                  ),

                  _optionDivider(isDark),

                  // İzin Yönetimi
                  _profileOption(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'İzin Yönetimi',
                    subtitle: 'Konum, hareket ve sağlık izinleri',
                    onTap: () {
                      context.push('/permission-settings');
                    },
                  ),

                  _optionDivider(isDark),

                  // Tema
                  _profileOption(
                    icon: Icons.brightness_6_outlined,
                    title: 'Tema',
                    subtitle: 'Görünüm ayarları',
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

  Widget _optionDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark
          ? _darkDivider
          : Theme.of(context).dividerColor,
    );
  }
}
