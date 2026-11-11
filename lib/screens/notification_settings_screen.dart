
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  final NotificationService _notifications =
      NotificationService.instance;

  bool _reminderEnabled = false;
  bool _goalEnabled = false;

  bool _loading = true;
  bool _saving = false;

  int _hour = 20;
  int _minute = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final reminder = await _prefs.getBool(
            NotificationService.reminderEnabledKey,
          ) ??
          false;

      final goal = await _prefs.getBool(
            NotificationService.goalEnabledKey,
          ) ??
          false;

      final hour = await _prefs.getInt(
            NotificationService.reminderHourKey,
          ) ??
          20;

      final minute = await _prefs.getInt(
            NotificationService.reminderMinuteKey,
          ) ??
          0;

      if (!mounted) return;

      setState(() {
        _reminderEnabled = reminder;
        _goalEnabled = goal;
        _hour = hour.clamp(0, 23);
        _minute = minute.clamp(0, 59);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showMessage('Ayarlar yüklenemedi: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String get _formattedTime =>
      '${_hour.toString().padLeft(2, '0')}:'
      '${_minute.toString().padLeft(2, '0')}';

  Future<void> _toggleReminder(bool value) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      if (value) {
        final granted =
            await _notifications.requestPermission();

        if (!granted) {
          _showMessage(
            'Bildirim izni verilmedi. '
            'Telefon ayarlarından açabilirsin.',
          );
          return;
        }

        await _notifications.scheduleDailyReminder(
          hour: _hour,
          minute: _minute,
        );
      } else {
        await _notifications.cancelDailyReminder();
      }

      await _prefs.setBool(
        NotificationService.reminderEnabledKey,
        value,
      );

      if (!mounted) return;

      setState(() => _reminderEnabled = value);
    } catch (e) {
      _showMessage('Hatırlatıcı kaydedilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _toggleGoal(bool value) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      if (value) {
        final granted =
            await _notifications.requestPermission();

        if (!granted) {
          _showMessage(
            'Hedef bildirimi için bildirim izni gerekli.',
          );
          return;
        }
      }

      await _prefs.setBool(
        NotificationService.goalEnabledKey,
        value,
      );

      if (!mounted) return;

      setState(() => _goalEnabled = value);

      _showMessage(
        value
            ? 'Hedef bildirimi açıldı.'
            : 'Hedef bildirimi kapatıldı.',
      );
    } catch (e) {
      _showMessage('Hedef bildirimi kaydedilemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _selectReminderTime() async {
    if (_saving) return;

    final now = DateTime.now();

    DateTime selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      _hour,
      _minute,
    );

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 12, 16, 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext)
                        .colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(sheetContext),
                      child: const Text('Vazgeç'),
                    ),
                    const Text(
                      'Hatırlatma Saati',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(
                            sheetContext,
                            selectedTime,
                          ),
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness:
                          Theme.of(sheetContext).brightness,
                      primaryColor:
                          Theme.of(sheetContext)
                              .colorScheme.primary,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      minuteInterval: 1,
                      initialDateTime: selectedTime,
                      onDateTimeChanged: (dateTime) {
                        selectedTime = dateTime;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() => _saving = true);

    try {
      if (_reminderEnabled) {
        await _notifications.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }

      await _prefs.setInt(
        NotificationService.reminderHourKey,
        picked.hour,
      );

      await _prefs.setInt(
        NotificationService.reminderMinuteKey,
        picked.minute,
      );

      if (!mounted) return;

      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });

      _showMessage('Hatırlatma saati güncellendi.');
    } catch (e) {
      _showMessage('Saat güncellenemedi: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _sendTestNotification() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final granted =
          await _notifications.requestPermission();

      if (!granted) {
        _showMessage('Bildirim izni verilmedi.');
        return;
      }

      await _notifications.showTestNotification();

      _showMessage('Test bildirimi gönderildi.');
    } catch (e) {
      _showMessage('Test bildirimi başarısız: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Bildirim Ayarları',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Günlük hareket hatırlatmalarını '
                  've hedef bildirimlerini yönet.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                          size: 26,
                        ),
                        title: const Text(
                          'Günlük Yürüyüş Hatırlatıcısı',
                        ),
                        subtitle: const Text(
                          'Her gün seçtiğin saatte '
                          'yürüyüş hatırlatması al.',
                        ),
                        value: _reminderEnabled,
                        onChanged: _saving
                            ? null
                            : _toggleReminder,
                      ),

                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),

                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        leading: const Icon(
                          Icons.access_time_rounded,
                        ),
                        title: const Text(
                          'Hatırlatma Saati',
                        ),
                        subtitle: Text(_formattedTime),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: _saving
                            ? null
                            : _selectReminderTime,
                      ),

                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),

                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        secondary: const Icon(
                          Icons.emoji_events_outlined,
                          size: 26,
                        ),
                        title: const Text(
                          'Adım Hedefi Bildirimi',
                        ),
                        subtitle: const Text(
                          'Günlük adım hedefine '
                          'ulaştığında tebrik bildirimi al.',
                        ),
                        value: _goalEnabled,
                        onChanged: _saving
                            ? null
                            : _toggleGoal,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : _sendTestNotification,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text(
                    'Test Bildirimi Gönder',
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Hedef bildirimi, uygulama sağlık '
                  'verilerini okuduğunda kontrol edilir. '
                  'Her gün en fazla bir kez gönderilir.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}
