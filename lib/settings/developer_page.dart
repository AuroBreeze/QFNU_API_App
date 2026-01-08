import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/shared/settings_store.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  bool _loading = true;
  bool _testNotifyEnabled = false;
  static const int _testNotificationId = 22001;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SettingsStore.getGradeTestNotificationEnabled();
    if (!mounted) return;
    setState(() {
      _testNotifyEnabled = enabled;
      _loading = false;
    });
  }

  Future<bool> _requestNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(initializationSettings);
    final android =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    final dynamic androidDynamic = android;
    try {
      final granted = await androidDynamic.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      try {
        final granted = await androidDynamic.requestPermission();
        return granted ?? false;
      } catch (_) {
        return true;
      }
    }
  }

  Future<void> _toggleTestNotify(bool value) async {
    if (value) {
      final granted = await _requestNotificationPermission();
      if (!granted) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _testNotifyEnabled = false;
        });
        await SettingsStore.setGradeTestNotificationEnabled(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationPermissionRequired)),
        );
        return;
      }
    }

    setState(() {
      _testNotifyEnabled = value;
    });
    await SettingsStore.setGradeTestNotificationEnabled(value);
    if (value) {
      await _scheduleTestNotification();
    } else {
      await _cancelTestNotification();
    }
  }

  Future<void> _scheduleTestNotification() async {
    final l10n = AppLocalizations.of(context)!;
    final plugin = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(initializationSettings);
    final scheduleMode = await _resolveScheduleMode(plugin);

    final androidDetails = AndroidNotificationDetails(
      'grade_test_notifications',
      l10n.testNotifyChannelName,
      channelDescription: l10n.testNotifyChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.cancel(_testNotificationId);
    await plugin.periodicallyShowWithDuration(
      _testNotificationId,
      l10n.testNotifyTitle,
      l10n.testNotifyBody,
      const Duration(minutes: 1),
      details,
      androidScheduleMode: scheduleMode,
    );
  }

  Future<void> _cancelTestNotification() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.cancel(_testNotificationId);
  }

  Future<AndroidScheduleMode> _resolveScheduleMode(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return AndroidScheduleMode.inexact;
    final dynamic androidDynamic = android;
    try {
      final canExact = await androidDynamic.canScheduleExactNotifications();
      if (canExact == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (_) {
      // Fall back to inexact scheduling when exact alarms are unavailable.
    }
    return AndroidScheduleMode.inexact;
  }

  Future<void> _showImmediateTestNotification() async {
    final granted = await _requestNotificationPermission();
    if (!granted) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationPermissionRequired)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final plugin = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(initializationSettings);

    final androidDetails = AndroidNotificationDetails(
      'grade_test_notifications',
      l10n.testNotifyChannelName,
      channelDescription: l10n.testNotifyChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.show(
      _testNotificationId + 1,
      l10n.testNotifyTitle,
      l10n.testNotifyBody,
      details,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.testNotifySent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.developerTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F1EA),
                  Color(0xFFE6F3EE),
                  Color(0xFFF1E9DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const GlowCircle(
            offset: Offset(-140, -120),
            size: 220,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const GlowCircle(
            offset: Offset(200, 120),
            size: 180,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                Card(
                  elevation: 10,
                  shadowColor: Colors.black26,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.testNotifyTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.testNotifySubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _testNotifyEnabled,
                          onChanged: _loading ? null : _toggleTestNotify,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.testNotifyEnabledLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          l10n.testNotifyHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showImmediateTestNotification,
                            icon: const Icon(Icons.notifications_outlined),
                            label: Text(l10n.testNotifyNowButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
