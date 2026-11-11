
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';

class StepService {
  final Health _health = Health();

  bool _isConfigured = false;

  // Health servisini hazırlar.
  Future<void> initialize() async {
    if (_isConfigured) return;

    await _health.configure();
    _isConfigured = true;
  }

  // Günlük adım verisini okumak için izin ister.
  // Bu metot izin ekranından çağrılacak.
  Future<bool> requestStepPermission() async {
    try {
      await initialize();

      return await _health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
    } catch (e) {
      debugPrint('Adım izni hatası: $e');
      return false;
    }
  }

  // Bugünün toplam adım sayısını Health üzerinden okur.
  // Bu metot kendi başına izin penceresi açmaz.
  Future<int?> getTodaySteps() async {
    try {
      await initialize();

      final now = DateTime.now();

      // Bugünün yerel saatle 00:00 başlangıcı.
      final midnight = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final steps = await _health.getTotalStepsInInterval(
        midnight,
        now,
        includeManualEntry: false,
      );

      return steps;
    } catch (e) {
      debugPrint('Günlük adım okuma hatası: $e');
      return null;
    }
  }

  // Belirli bir günün toplam adımlarını okur.
  Future<int?> getStepsForDate(DateTime date) async {
    try {
      await initialize();

      final start = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final nextDay = DateTime(
        date.year,
        date.month,
        date.day + 1,
      );

      final now = DateTime.now();
      final end = nextDay.isAfter(now) ? now : nextDay;

      if (!end.isAfter(start)) {
        return null;
      }

      return await _health.getTotalStepsInInterval(
        start,
        end,
        includeManualEntry: false,
      );
    } catch (e) {
      debugPrint('Geçmiş adım okuma hatası: $e');
      return null;
    }
  }

  // Telefonun canlı adım sensörünü dinler.
  Stream<StepCount> getStepCountStream() {
    return Pedometer.stepCountStream;
  }

  // Hareket durumunu dinler: walking / stopped.
  Stream<PedestrianStatus> getPedestrianStatusStream() {
    return Pedometer.pedestrianStatusStream;
  }
}
