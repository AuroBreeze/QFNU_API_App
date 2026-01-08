import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:qfnu_app/background/grade_check_worker.dart';
import 'package:qfnu_app/shared/settings_store.dart';

class GradeCheckScheduler {
  static bool _isAndroid() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<void> initialize() async {
    if (!_isAndroid()) return;
    await Workmanager().initialize(gradeCheckDispatcher, isInDebugMode: false);
    await syncWithSettings();
  }

  static Future<void> syncWithSettings() async {
    if (!_isAndroid()) return;
    final enabled = await SettingsStore.getGradeNotificationEnabled();
    if (!enabled) {
      await Workmanager().cancelByUniqueName(gradeCheckTaskName);
      return;
    }

    final hours = await SettingsStore.getGradeCheckIntervalHours();
    await Workmanager().registerPeriodicTask(
      gradeCheckTaskName,
      gradeCheckTaskName,
      frequency: Duration(hours: hours),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 30),
    );
  }

}
