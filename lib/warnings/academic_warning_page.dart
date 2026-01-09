import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/login_page.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class AcademicWarningPage extends StatefulWidget {
  final LoginService service;
  final String username;

  const AcademicWarningPage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  State<AcademicWarningPage> createState() => _AcademicWarningPageState();
}

class _AcademicWarningPageState extends State<AcademicWarningPage> {
  List<AcademicWarningItem> _items = [];
  AcademicWarningSummary? _summary;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWarnings();
  }

  Future<void> _handleSessionExpired() async {
    await widget.service.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _loadWarnings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.service.fetchAcademicWarnings();
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _summary = result.summary;
      });
    } on SessionExpiredException {
      if (!mounted) return;
      await _handleSessionExpired();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadAcademicWarnings(error.toString());
        _items = [];
        _summary = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Color _resultColor(String result, ThemeData theme) {
    if (result.contains('红')) return Colors.redAccent;
    if (result.contains('黄')) return Colors.orangeAccent;
    if (result.contains('绿')) return Colors.green;
    return theme.colorScheme.primary;
  }

  Widget _buildLine(
    ThemeData theme,
    String label,
    String value,
  ) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '$label：$value',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
      ),
    );
  }

  Widget _buildWarningCard(
    AcademicWarningItem item,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final name = item.name.isEmpty ? l10n.academicWarningUnnamed : item.name;
    final resultColor = _resultColor(item.result, theme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (item.result.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.result,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (item.term.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${l10n.academicWarningTermLabel}：${item.term}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
          _buildLine(theme, l10n.academicWarningConditionLabel, item.condition),
          _buildLine(theme, l10n.academicWarningMessageLabel, item.message),
          _buildLine(theme, l10n.academicWarningTargetLabel, item.target),
          _buildLine(theme, l10n.academicWarningActualLabel, item.actual),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    AcademicWarningSummary summary,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            summary.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.academicWarningTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadWarnings,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.reload,
          ),
        ],
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: (_items.isEmpty && _summary == null)
                        ? Center(
                            child: Text(
                              _loading
                                  ? l10n.loading
                                  : l10n.noAcademicWarningData,
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length + (_summary == null ? 0 : 1),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (_summary != null && index == 0) {
                                return _buildSummaryCard(_summary!, theme);
                              }
                              final offset = _summary == null ? 0 : 1;
                              final item = _items[index - offset];
                              return _buildWarningCard(item, theme, l10n);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
