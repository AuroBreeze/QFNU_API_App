import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const String _keyTrainingPlanCacheDays = 'training_plan_cache_days';
  static const int defaultTrainingPlanCacheDays = 7;
  static const String _keyGradeNotifyEnabled = 'grade_notify_enabled';
  static const String _keyGradeCheckIntervalHours = 'grade_check_interval_hours';
  static const int defaultGradeCheckIntervalHours = 6;
  static const String _keyGradeTestNotifyEnabled = 'grade_test_notify_enabled';
  static const String _keyTributePromptEnabled = 'tribute_prompt_enabled';
  static const String _keyTributePromptShown = 'tribute_prompt_shown';
  static const String _keyShowHomeTributeCard = 'show_home_tribute_card';

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

  static Future<bool> getGradeTestNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGradeTestNotifyEnabled) ?? false;
  }

  static Future<void> setGradeTestNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGradeTestNotifyEnabled, enabled);
  }

  static Future<bool> getTributePromptEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTributePromptEnabled) ?? true;
  }

  static Future<void> setTributePromptEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTributePromptEnabled, enabled);
  }

  static Future<bool> getTributePromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTributePromptShown) ?? false;
  }

  static Future<void> setTributePromptShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTributePromptShown, shown);
  }

  static Future<bool> getShowHomeTributeCard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowHomeTributeCard) ?? true;
  }

  static Future<void> setShowHomeTributeCard(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowHomeTributeCard, show);
  }
}
