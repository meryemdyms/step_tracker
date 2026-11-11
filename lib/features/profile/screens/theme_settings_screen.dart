
import 'package:flutter/material.dart';

import '../../../core/services/theme_service.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool _isSaving = false;

  static const Color _blue = Color(0xFF65A7C1);

  Future<void> _selectTheme(ThemeMode mode) async {
    if (_isSaving || themeService.themeMode == mode) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await themeService.setTheme(mode);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tema tercihi kaydedilemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _themeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode selectedMode,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = selectedMode == mode;

    return ListTile(
      enabled: !_isSaving,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: _blue,
          size: 25,
        ),
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
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.circle_outlined,
        color: selected ? _blue : colors.outline,
        size: 26,
      ),
      onTap: () => _selectTheme(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        final selectedMode = themeService.themeMode;

        return Scaffold(
          backgroundColor: isDark
              ? theme.scaffoldBackgroundColor
              : const Color(0xFFF7FAFC),
          appBar: AppBar(
            title: const Text('Tema Ayarları'),
            centerTitle: true,
            backgroundColor: isDark
                ? theme.scaffoldBackgroundColor
                : const Color(0xFFF7FAFC),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 18),

                Text(
                  'Görünüm Tercihi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Uygulamanın görünümünü dilediğin '
                  'gibi özelleştirebilirsin.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 26),

                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surface
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _themeOption(
                        icon: Icons.wb_sunny_outlined,
                        title: 'Açık Tema',
                        subtitle: 'Aydınlık görünüm',
                        mode: ThemeMode.light,
                        selectedMode: selectedMode,
                      ),

                      const Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                      ),

                      _themeOption(
                        icon: Icons.dark_mode_outlined,
                        title: 'Koyu Tema',
                        subtitle: 'Karanlık görünüm',
                        mode: ThemeMode.dark,
                        selectedMode: selectedMode,
                      ),

                      const Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                      ),

                      _themeOption(
                        icon: Icons.settings_brightness_rounded,
                        title: 'Sistem Teması',
                        subtitle: 'Telefonun görünümünü takip et',
                        mode: ThemeMode.system,
                        selectedMode: selectedMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Seçtiğin tema otomatik olarak kaydedilir '
                  've uygulamanın tamamına uygulanır.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
