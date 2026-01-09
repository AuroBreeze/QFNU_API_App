import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({
    super.key,
    this.showActions = false,
    this.onAccept,
    this.onDecline,
  });

  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final paragraphs = [
      l10n.disclaimerBody1,
      l10n.disclaimerBody2,
      l10n.disclaimerBody3,
      l10n.disclaimerBody4,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.disclaimerTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !showActions,
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
                        l10n.disclaimerHeadline,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.disclaimerSubtitle,
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
                      if (showActions) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onDecline,
                                child: Text(l10n.disclaimerDecline),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: onAccept,
                                child: Text(l10n.disclaimerAccept),
                              ),
                            ),
                          ],
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
