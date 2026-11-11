
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStatusService {
  static const String _completedKey = 'onboarding_completed';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<bool> isCompleted() async {
    return await _prefs.getBool(_completedKey) ?? false;
  }

  Future<void> markCompleted() async {
    await _prefs.setBool(_completedKey, true);
  }
}
