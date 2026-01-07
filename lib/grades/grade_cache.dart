import 'package:shared_preferences/shared_preferences.dart';

class GradeCacheStore {
  static const String _keySignatures = 'grade_cache_signatures';

  static Future<Set<String>> readSignatures() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySignatures);
    if (list == null) return <String>{};
    return list.where((item) => item.isNotEmpty).toSet();
  }

  static Future<void> writeSignatures(Set<String> signatures) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySignatures, signatures.toList());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySignatures);
  }
}
