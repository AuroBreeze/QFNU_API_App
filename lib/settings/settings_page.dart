import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final days = await SettingsStore.getTrainingPlanCacheDays();
    if (!mounted) return;
    setState(() {
      _cacheDays = days;
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
