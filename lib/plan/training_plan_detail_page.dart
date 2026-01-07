import 'package:flutter/material.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';

class TrainingPlanDetailPage extends StatelessWidget {
  final TrainingPlanGroup group;

  const TrainingPlanDetailPage({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed =
        group.courses.where((course) => course.completed).toList();
    final pending =
        group.courses.where((course) => !course.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Plan'),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ListView(
                children: [
                  _buildSummaryCard(theme),
                  const SizedBox(height: 14),
                  _buildSectionHeader('Completed', completed.length, theme),
                  const SizedBox(height: 8),
                  if (completed.isEmpty)
                    _emptyHint('No completed courses.', theme)
                  else
                    ...completed
                        .map((course) => _buildCourseCard(course, theme))
                        .expand((widget) => [widget, const SizedBox(height: 10)]),
                  const SizedBox(height: 6),
                  _buildSectionHeader('Pending', pending.length, theme),
                  const SizedBox(height: 8),
                  if (pending.isEmpty)
                    _emptyHint('No pending courses.', theme)
                  else
                    ...pending
                        .map((course) => _buildCourseCard(course, theme))
                        .expand((widget) => [widget, const SizedBox(height: 10)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final progress = group.progress;
    final percentText =
        progress == null ? '--' : '${(progress * 100).toStringAsFixed(0)}%';
    final barValue = progress == null ? 0.0 : progress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: barValue,
                    minHeight: 8,
                    backgroundColor: Colors.black12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                percentText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completed ${group.completedCredits} / Required ${group.requiredCredits}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Total hours: ${group.totalHours}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(TrainingPlanCourse course, ThemeData theme) {
    final statusText = course.status.isEmpty
        ? (course.completed ? 'Completed' : 'Pending')
        : course.status;
    final statusColor =
        course.completed ? theme.colorScheme.primary : Colors.orange.shade700;
    final detailItems = <String>[];
    if (course.attribute.isNotEmpty) {
      detailItems.add('Attribute: ${course.attribute}');
    }
    if (course.credits.isNotEmpty) {
      detailItems.add('Credits: ${course.credits}');
    }
    if (course.term.isNotEmpty) {
      detailItems.add('Term: ${course.term}');
    }
    if (course.totalHours.isNotEmpty) {
      detailItems.add('Hours: ${course.totalHours}');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.name.isEmpty ? course.code : course.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (course.code.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              course.code,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (detailItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: detailItems
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyHint(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
      ),
    );
  }
}
