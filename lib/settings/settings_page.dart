import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qfnu_app/background/grade_check_scheduler.dart';
import 'package:qfnu_app/disclaimer/disclaimer_page.dart';
import 'package:qfnu_app/settings/developer_page.dart';
import 'package:qfnu_app/settings/tribute_page.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/shared/settings_store.dart';
import 'package:qfnu_app/shared/training_plan_cache.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  int _cacheDays = SettingsStore.defaultTrainingPlanCacheDays;
  bool _gradeNotifyEnabled = true;
  int _gradeCheckHours = SettingsStore.defaultGradeCheckIntervalHours;
  bool _tributePromptEnabled = true;
  bool _showHomeTributeCard = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final days = await SettingsStore.getTrainingPlanCacheDays();
    final gradeEnabled = await SettingsStore.getGradeNotificationEnabled();
    final gradeHours = await SettingsStore.getGradeCheckIntervalHours();
    final tributePromptEnabled = await SettingsStore.getTributePromptEnabled();
    final showHomeTributeCard = await SettingsStore.getShowHomeTributeCard();
    if (!mounted) return;
    setState(() {
      _cacheDays = days;
      _gradeNotifyEnabled = gradeEnabled;
      _gradeCheckHours = gradeHours;
      _tributePromptEnabled = tributePromptEnabled;
      _showHomeTributeCard = showHomeTributeCard;
      _loading = false;
    });
  }

  Future<void> _updateCacheDays(double value) async {
    final days = value.round();
    setState(() {
      _cacheDays = days;
    });
    await SettingsStore.setTrainingPlanCacheDays(days);
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

  Future<void> _toggleGradeNotify(bool value) async {
    if (value) {
      final granted = await _requestNotificationPermission();
      if (!granted) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _gradeNotifyEnabled = false;
        });
        await SettingsStore.setGradeNotificationEnabled(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationPermissionRequired)),
        );
        await GradeCheckScheduler.syncWithSettings();
        return;
      }
    }

    setState(() {
      _gradeNotifyEnabled = value;
    });
    await SettingsStore.setGradeNotificationEnabled(value);
    await GradeCheckScheduler.syncWithSettings();
  }

  Future<void> _toggleTributePrompt(bool value) async {
    setState(() {
      _tributePromptEnabled = value;
    });
    await SettingsStore.setTributePromptEnabled(value);
  }

  Future<void> _toggleHomeTributeCard(bool value) async {
    setState(() {
      _showHomeTributeCard = value;
    });
    await SettingsStore.setShowHomeTributeCard(value);
  }


  void _previewGradeInterval(double value) {
    setState(() {
      _gradeCheckHours = value.round();
    });
  }

  Future<void> _commitGradeInterval(double value) async {
    final hours = value.round();
    setState(() {
      _gradeCheckHours = hours;
    });
    await SettingsStore.setGradeCheckIntervalHours(hours);
    await GradeCheckScheduler.syncWithSettings();
  }

  Future<void> _clearTrainingPlanCache() async {
    await TrainingPlanCache.clear();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.cacheClearedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
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
                          l10n.trainingPlanCacheTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.trainingPlanCacheSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.cacheDaysLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _cacheDays.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                label: l10n.cacheDaysValue(_cacheDays),
                                onChanged: _loading ? null : _updateCacheDays,
                              ),
                            ),
                            Text(
                              l10n.cacheDaysValue(_cacheDays),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _clearTrainingPlanCache,
                            icon: const Icon(Icons.delete_outline),
                            label: Text(l10n.cacheClearButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.gradeNotifySectionTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.gradeNotifyBetaLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.gradeNotifySectionSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _gradeNotifyEnabled,
                          onChanged: _loading ? null : _toggleGradeNotify,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.gradeNotifyEnabledLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.gradeNotifyIntervalLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _gradeCheckHours.toDouble(),
                                min: 1,
                                max: 24,
                                divisions: 23,
                                label:
                                    l10n.gradeNotifyIntervalValue(_gradeCheckHours),
                                onChanged: !_gradeNotifyEnabled || _loading
                                    ? null
                                    : _previewGradeInterval,
                                onChangeEnd: !_gradeNotifyEnabled || _loading
                                    ? null
                                    : _commitGradeInterval,
                              ),
                            ),
                            Text(
                              l10n.gradeNotifyIntervalValue(_gradeCheckHours),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                          l10n.tributePromptTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tributePromptSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _tributePromptEnabled,
                          onChanged: _loading ? null : _toggleTributePrompt,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.tributePromptEnabledLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                          l10n.tributeHomeCardTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tributeHomeCardSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _showHomeTributeCard,
                          onChanged: _loading ? null : _toggleHomeTributeCard,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.tributeHomeCardEnabledLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.disclaimerEntryTitle),
                    subtitle: Text(l10n.disclaimerEntrySubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DisclaimerPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: Text(l10n.tributeTitle),
                    subtitle: Text(l10n.tributeSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TributePage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.code_outlined),
                    title: Text(l10n.developerTitle),
                    subtitle: Text(l10n.developerSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DeveloperPage(),
                        ),
                      );
                    },
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
