import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/settings_store.dart';

class WeekInfoCard extends StatefulWidget {
  final LoginService service;

  const WeekInfoCard({
    super.key,
    required this.service,
  });

  @override
  State<WeekInfoCard> createState() => _WeekInfoCardState();
}

class _WeekInfoCardState extends State<WeekInfoCard> {
  Future<WeekInfo?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadWeekInfo();
  }

  Future<WeekInfo?> _loadWeekInfo() async {
    try {
      final info = await widget.service.fetchCurrentWeekInfo();
      if (info != null) {
        await SettingsStore.setSavedWeekInfo(info);
        return info;
      }
    } catch (_) {
      // Ignore and fall back to saved value.
    }
    return SettingsStore.getSavedWeekInfo();
  }

  void _refresh() {
    setState(() {
      _future = _loadWeekInfo();
    });
  }

  String _formatWeek(AppLocalizations l10n, WeekInfo info) {
    final total = info.totalWeeks;
    if (total == null || total <= 0) {
      return l10n.currentWeekValue(info.currentWeek);
    }
    return l10n.currentWeekValueWithTotal(info.currentWeek, total);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _refresh,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentWeekTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<WeekInfo?>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            l10n.loading,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                          );
                        }
                        final info = snapshot.data;
                        final text = info == null
                            ? l10n.currentWeekUnknown
                            : _formatWeek(l10n, info);
                        return Text(
                          text,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.refresh,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
