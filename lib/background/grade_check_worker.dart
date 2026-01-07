import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:qfnu_app/grades/grade_cache.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/direct_login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/settings_store.dart';

const String gradeCheckTaskName = 'grade_check_task';

@pragma('vm:entry-point')
void gradeCheckDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await GradeCheckWorker.run();
    return true;
  });
}

class GradeCheckWorker {
  static Future<void> run() async {
    final enabled = await SettingsStore.getGradeNotificationEnabled();
    if (!enabled) return;

    final service = await DirectLoginService.create();
    List<GradeItem> items;
    try {
      items = await service.fetchGrades(
        kksj: '',
        kcxz: '',
        kcmc: '',
        xsfs: 'all',
      );
    } on SessionExpiredException {
      return;
    } catch (_) {
      return;
    }

    final current = items
        .map(
          (item) =>
              '${item.courseCode.trim()}|${item.score.trim()}',
        )
        .where((value) => value.isNotEmpty)
        .toSet();

    final previous = await GradeCacheStore.readSignatures();
    if (previous.isEmpty) {
      await GradeCacheStore.writeSignatures(current);
      return;
    }

    final newItems = current.difference(previous);
    if (newItems.isEmpty) {
      return;
    }

    await GradeCacheStore.writeSignatures(current);
    await _showNotification(newItems.length);
  }

  static Future<void> _showNotification(int count) async {
    final l10n = _resolveL10n();
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await plugin.initialize(initializationSettings);

    const channelId = 'grade_updates';
    final androidDetails = AndroidNotificationDetails(
      channelId,
      l10n.gradeNotifyChannelName,
      channelDescription: l10n.gradeNotifyChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.show(
      channelId.hashCode,
      l10n.gradeNotifyTitle,
      l10n.gradeNotifyBody(count),
      details,
    );
  }

  static AppLocalizations _resolveL10n() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    try {
      return lookupAppLocalizations(locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('zh'));
    }
  }
}
