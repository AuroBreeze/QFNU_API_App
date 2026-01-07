import 'package:shared_preferences/shared_preferences.dart';
import 'package:qfnu_app/shared/settings_store.dart';

class TrainingPlanCacheEntry {
  final String html;
  final DateTime updatedAt;

  const TrainingPlanCacheEntry({
    required this.html,
    required this.updatedAt,
  });
}

class TrainingPlanCache {
  static const String _keyHtml = 'training_plan_cache_html';
  static const String _keyUpdatedAt = 'training_plan_cache_updated_at';

  static Future<TrainingPlanCacheEntry?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final html = prefs.getString(_keyHtml);
    final millis = prefs.getInt(_keyUpdatedAt);
    if (html == null || html.isEmpty || millis == null) {
      return null;
    }
    return TrainingPlanCacheEntry(
      html: html,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  static Future<void> write(String html) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHtml, html);
    await prefs.setInt(
      _keyUpdatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHtml);
    await prefs.remove(_keyUpdatedAt);
  }

  static bool isFresh(TrainingPlanCacheEntry entry, int days) {
    final expiresAt = entry.updatedAt.add(Duration(days: days));
    return DateTime.now().isBefore(expiresAt);
  }

  static Future<String?> getFreshHtml() async {
    final entry = await read();
    if (entry == null) return null;
    final days = await SettingsStore.getTrainingPlanCacheDays();
    if (!isFresh(entry, days)) return null;
    return entry.html;
  }
}
