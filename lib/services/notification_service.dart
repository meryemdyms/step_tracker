
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final SharedPreferencesAsync _prefs =
      SharedPreferencesAsync();

  // SharedPreferences anahtarları
  static const String reminderEnabledKey =
      'daily_reminder_enabled';

  static const String reminderHourKey =
      'daily_reminder_hour';

  static const String reminderMinuteKey =
      'daily_reminder_minute';

  static const String goalEnabledKey =
      'goal_notification_enabled';

  static const String lastGoalNotificationKey =
      'last_goal_notification_date';

  // Bildirim ID'leri
  static const int reminderId = 1001;
  static const int testId = 1002;
  static const int goalId = 1003;

  // Bildirim kanalları
  static const String reminderChannelId =
      'daily_walking_reminder';

  static const String reminderChannelName =
      'Yürüyüş Hatırlatmaları';

  static const String goalChannelId =
      'daily_step_goal';

  static const String goalChannelName =
      'Adım Hedefi';

  bool _initialized = false;
  Future<void>? _initialization;
  bool _checkingGoal = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // Bildirim servisini başlat
  Future<void> initialize() async {
    if (_initialized || !_supported) return;

    if (_initialization != null) {
      return _initialization!;
    }

    _initialization = _initializeInternal();

    try {
      await _initialization;
      _initialized = true;
    } finally {
      _initialization = null;
    }
  }

  Future<void> _initializeInternal() async {
    // Android: Mevcut StepPulse uygulama ikonu
    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS: Uygulama ikonu otomatik kullanılır
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings: settings);

    // Yerel saat dilimi
    tz.initializeTimeZones();

    final timezone =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezone.identifier),
    );
  }

  // Bildirim izni
  Future<bool> requestPermission() async {
    if (!_supported) return false;

    await initialize();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await android
            ?.requestNotificationsPermission() ??
        false;
  }

  // Bir sonraki hatırlatma saatini hesapla
  tz.TZDateTime _nextReminderTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    return scheduled;
  }

  // Günlük yürüyüş hatırlatması
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_supported) {
      throw UnsupportedError(
        'Bildirimler yalnızca Android ve iOS içindir.',
      );
    }

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      throw ArgumentError('Geçersiz saat.');
    }

    await initialize();

    await _plugin.cancel(id: reminderId);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        reminderChannelId,
        reminderChannelName,
        channelDescription:
            'StepPulse günlük yürüyüş hatırlatmaları',
        icon: '@mipmap/ic_launcher',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: reminderId,
      title: 'StepPulse - Yürüyüş zamanı',
      body:
          'Bugün biraz hareket etmeye ne dersin? '
          'Adım hedefine bir adım daha yaklaş.',
      scheduledDate: _nextReminderTime(
        hour: hour,
        minute: minute,
      ),
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Günlük hatırlatmayı iptal et
  Future<void> cancelDailyReminder() async {
    if (!_supported) return;

    await initialize();
    await _plugin.cancel(id: reminderId);
  }

  // Test bildirimi
  Future<void> showTestNotification() async {
    if (!_supported) return;

    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        reminderChannelId,
        reminderChannelName,
        channelDescription:
            'StepPulse günlük yürüyüş hatırlatmaları',
        icon: '@mipmap/ic_launcher',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: testId,
      title: 'StepPulse - Bildirim Testi',
      body: 'Yürüyüş hatırlatıcıların hazır.',
      notificationDetails: details,
    );
  }

  // Bugünün tarih anahtarı
  String _todayKey() {
    final now = DateTime.now();

    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }

  // Günlük adım hedefi kontrolü
  Future<void> checkDailyStepGoal({
    required int steps,
    required int goal,
  }) async {
    if (!_supported || _checkingGoal) return;

    if (goal <= 0 || steps < goal) return;

    _checkingGoal = true;

    try {
      final enabled =
          await _prefs.getBool(goalEnabledKey) ?? false;

      if (!enabled) return;

      final today = _todayKey();

      final lastNotified =
          await _prefs.getString(lastGoalNotificationKey);

      // Bugün zaten bildirim gönderildiyse çık
      if (lastNotified == today) return;

      await initialize();

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          goalChannelId,
          goalChannelName,
          channelDescription:
              'StepPulse günlük adım hedefi bildirimleri',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      );

      await _plugin.show(
        id: goalId,
        title: 'StepPulse - Hedef tamamlandı!',
        body:
            'Tebrikler! Bugün $steps adım attın '
            've $goal adımlık hedefine ulaştın.',
        notificationDetails: details,
      );

      // Başarılı gönderimden sonra kaydet
      await _prefs.setString(
        lastGoalNotificationKey,
        today,
      );
    } catch (e) {
      debugPrint('Hedef bildirimi hatası: $e');
    } finally {
      _checkingGoal = false;
    }
  }
}
