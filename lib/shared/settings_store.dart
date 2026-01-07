import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const String _keyTrainingPlanCacheDays = 'training_plan_cache_days';
  static const int defaultTrainingPlanCacheDays = 7;
  static const String _keyGradeNotifyEnabled = 'grade_notify_enabled';
  static const String _keyGradeCheckIntervalHours = 'grade_check_interval_hours';
  static const int defaultGradeCheckIntervalHours = 6;

  static int _normalizeDays(int value) {
    if (value < 1) return 1;
    if (value > 30) return 30;
    return value;
  }

  static int _normalizeHours(int value) {
    if (value < 1) return 1;
    if (value > 24) return 24;
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

  static Future<bool> getGradeNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGradeNotifyEnabled) ?? true;
  }

  static Future<void> setGradeNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGradeNotifyEnabled, enabled);
  }

  static Future<int> getGradeCheckIntervalHours() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyGradeCheckIntervalHours);
    if (value == null) return defaultGradeCheckIntervalHours;
    return _normalizeHours(value);
  }

  static Future<void> setGradeCheckIntervalHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGradeCheckIntervalHours, _normalizeHours(hours));
  }
}
