import 'package:flutter/material.dart';
import 'package:qfnu_app/exams/exam_schedule_card.dart';
import 'package:qfnu_app/grades/grade_query_card.dart';
import 'package:qfnu_app/classroom/classroom_search_card.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/login/login_page.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/plan/training_plan_card.dart';
import 'package:qfnu_app/settings/settings_page.dart';
import 'package:qfnu_app/settings/tribute_page.dart';
import 'package:qfnu_app/shared/settings_store.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';
import 'package:qfnu_app/timetable/today_schedule_card.dart';
import 'package:qfnu_app/warnings/academic_warning_card.dart';

class HomePage extends StatelessWidget {
  final LoginService service;
  final String username;

  const HomePage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = username.trim();
    final greeting =
        name.isEmpty ? l10n.welcomeBack : l10n.welcomeUser(name);

    return Scaffold(
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
            size: 240,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const GlowCircle(
            offset: Offset(210, 120),
            size: 180,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.dashboardTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: l10n.settingsTitle,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await service.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.logout),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    greeting,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<bool>(
                    future: SettingsStore.getShowHomeTributeCard(),
                    builder: (context, snapshot) {
                      final showCard = snapshot.data ?? true;
                      if (!showCard) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                        ],
                      );
                    },
                  ),
                  TodayScheduleCard(
                    service: service,
                    username: username,
                  ),
                  const SizedBox(height: 16),
                  ExamScheduleCard(
                    service: service,
                    username: username,
                  ),
                  const SizedBox(height: 16),
                  AcademicWarningCard(
                    service: service,
                    username: username,
                  ),
                  const SizedBox(height: 16),
                  ClassroomSearchCard(
                    service: service,
                    username: username,
                  ),
                  const SizedBox(height: 16),
                  GradeQueryCard(
                    service: service,
                    username: username,
                  ),
                  const SizedBox(height: 16),
                  TrainingPlanCard(
                    service: service,
                    username: username,
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
