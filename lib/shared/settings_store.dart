import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const String _keyTrainingPlanCacheDays = 'training_plan_cache_days';
  static const int defaultTrainingPlanCacheDays = 7;

  static int _normalizeDays(int value) {
    if (value < 1) return 1;
    if (value > 30) return 30;
    return value;
  }

  static Future<int> getTrainingPlanCacheDays() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyTrainingPlanCacheDays);
    if (value == null) return defaultTrainingPlanCacheDays;
    return _normalizeDays(value);
  }

  static Future<void> setTrainingPlanCacheDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTrainingPlanCacheDays, _normalizeDays(days));
  }
}
