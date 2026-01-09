import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/shared/settings_store.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class TributePage extends StatefulWidget {
  const TributePage({super.key, this.showContinueButton = false});

  final bool showContinueButton;

  @override
  State<TributePage> createState() => _TributePageState();
}

class _TributePageState extends State<TributePage> {
  bool _promptEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SettingsStore.getTributePromptEnabled();
    if (!mounted) return;
    setState(() {
      _promptEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _togglePrompt(bool value) async {
    setState(() {
      _promptEnabled = value;
    });
    await SettingsStore.setTributePromptEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final paragraphs = [
      l10n.tributeBody1,
      l10n.tributeBody2,
      l10n.tributeBody3,
      l10n.tributeBody4,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tributeTitle),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Card(
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
                        l10n.tributeHeadline,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tributeSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final text in paragraphs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
                      const Divider(height: 20),
                      Text(
                        l10n.tributePromptTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
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
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        value: _promptEnabled,
                        onChanged: _loading ? null : _togglePrompt,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          l10n.tributePromptEnabledLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.showContinueButton) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.tributeContinue),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
