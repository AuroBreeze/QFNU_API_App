import 'package:qfnu_app/shared/models.dart';

String _decodeHtmlEntities(String text) {
  return text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}

String _stripHtml(String text) {
  final withoutTags = text.replaceAll(RegExp(r'<[^>]+>'), '');
  final decoded = _decodeHtmlEntities(withoutTags);
  return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _looksLikeLoginPage(String html) {
  if (RegExp(r'LoginToXkLdap', caseSensitive: false).hasMatch(html)) {
    return true;
  }
  final hasUser = RegExp(
    'name\\s*=\\s*[\\\'"]userAccount[\\\'"]',
    caseSensitive: false,
  ).hasMatch(html);
  final hasCaptcha = RegExp(
    'name\\s*=\\s*[\\\'"]RANDOMCODE[\\\'"]',
    caseSensitive: false,
  ).hasMatch(html);
  return hasUser && hasCaptcha;
}

bool looksLikeLoginPage(String html) {
  return _looksLikeLoginPage(html);
}

String? parseLoginErrorMessage(String html) {
  final match = RegExp(
    '<li[^>]*id=["\']showMsg["\'][^>]*>(.*?)</li>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (match == null) return null;
  final text = _stripHtml(match.group(1) ?? '');
  if (text.isEmpty) return null;
  return text;
}

void _throwIfSessionExpired(String html) {
  if (_looksLikeLoginPage(html)) {
    throw const SessionExpiredException();
  }
}

List<TermOption> parseSelectOptions(
  String html,
  String selectId, {
  bool includeEmpty = false,
}) {
  _throwIfSessionExpired(html);
  final escapedId = RegExp.escape(selectId);
  final selectMatch = RegExp(
    '<select[^>]*id="$escapedId"[^>]*>(.*?)</select>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (selectMatch == null) return [];

  final optionsHtml = selectMatch.group(1) ?? '';
  final optionMatches = RegExp(
    r'<option([^>]*)>(.*?)</option>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(optionsHtml);

  final options = <TermOption>[];
  for (final match in optionMatches) {
    final attrs = match.group(1) ?? '';
    final valueMatch = RegExp(
      "value\\s*=\\s*['\\\"]([^'\\\"]+)['\\\"]",
      caseSensitive: false,
    ).firstMatch(attrs);
    final value = valueMatch?.group(1) ?? '';
    final label = _stripHtml(match.group(2) ?? '');
    final selected =
        RegExp(r'\bselected\b', caseSensitive: false).hasMatch(attrs);
    if (value.isEmpty && !includeEmpty) continue;
    final displayLabel =
        label.isEmpty ? (value.isEmpty ? 'All' : value) : label;
    options.add(
      TermOption(
        value: value,
        label: displayLabel,
        selected: selected,
      ),
    );
  }

  return options;
}

List<TermOption> parseTermOptions(String html) {
  return parseSelectOptions(html, 'xnxqid');
}

GradeQueryOptions parseGradeQueryOptions(String html) {
  return GradeQueryOptions(
    terms: parseSelectOptions(html, 'kksj', includeEmpty: true),
    courseTypes: parseSelectOptions(html, 'kcxz', includeEmpty: true),
    displayModes: parseSelectOptions(html, 'xsfs'),
  );
}

List<ExamItem> parseExamList(String html) {
  _throwIfSessionExpired(html);
  final tableMatch = RegExp(
    r'<table[^>]*id="dataList"[^>]*>(.*?)</table>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (tableMatch == null) return [];

  final tableHtml = tableMatch.group(1) ?? '';
  final rowMatches = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(tableHtml);

  final items = <ExamItem>[];
  for (final row in rowMatches) {
    final rowHtml = row.group(1) ?? '';
    if (rowHtml.contains('<th')) continue;

    final cellMatches = RegExp(
      r'<td[^>]*>(.*?)</td>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(rowHtml);

    final cells = <String>[];
    for (final cell in cellMatches) {
      cells.add(_stripHtml(cell.group(1) ?? ''));
    }

    if (cells.length < 9) continue;

    items.add(
      ExamItem(
        courseCode: cells[3],
        courseName: cells[4],
        teacher: cells[5],
        time: cells[6],
        place: cells[7],
        seat: cells[8],
      ),
    );
  }

  return items;
}

List<GradeItem> parseGradeList(String html) {
  _throwIfSessionExpired(html);
  final tableMatch = RegExp(
    r'<table[^>]*id="dataList"[^>]*>(.*?)</table>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (tableMatch == null) return [];

  final tableHtml = tableMatch.group(1) ?? '';
  final rowMatches = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(tableHtml);

  final items = <GradeItem>[];
  for (final row in rowMatches) {
    final rowHtml = row.group(1) ?? '';
    if (rowHtml.contains('<th')) continue;

    final cellMatches = RegExp(
      r'<td[^>]*>(.*?)</td>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(rowHtml);

    final cells = <String>[];
    for (final cell in cellMatches) {
      cells.add(_stripHtml(cell.group(1) ?? ''));
    }

    if (cells.length < 10) continue;

    items.add(
      GradeItem(
        term: cells.length > 1 ? cells[1] : '',
        courseCode: cells.length > 2 ? cells[2] : '',
        courseName: cells.length > 3 ? cells[3] : '',
        groupName: cells.length > 4 ? cells[4] : '',
        score: cells.length > 5 ? cells[5] : '',
        scoreFlag: cells.length > 6 ? cells[6] : '',
        credit: cells.length > 7 ? cells[7] : '',
        hours: cells.length > 8 ? cells[8] : '',
        gradePoint: cells.length > 9 ? cells[9] : '',
        retakeTerm: cells.length > 10 ? cells[10] : '',
        assessmentMethod: cells.length > 11 ? cells[11] : '',
        examNature: cells.length > 12 ? cells[12] : '',
        courseAttribute: cells.length > 13 ? cells[13] : '',
        courseNature: cells.length > 14 ? cells[14] : '',
        courseCategory: cells.length > 15 ? cells[15] : '',
      ),
    );
  }

  return items;
}

int? _parseInt(String value) {
  final match = RegExp(r'-?\d+').firstMatch(value);
  if (match == null) return null;
  return int.tryParse(match.group(0) ?? '');
}

String _extractNumberText(String value) {
  final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(value);
  return match?.group(0) ?? '';
}

class _TrainingPlanAccumulator {
  final String name;
  int requiredCredits;
  int completedCredits;
  int totalHours;
  final List<TrainingPlanCourse> courses;

  _TrainingPlanAccumulator({
    required this.name,
    required this.requiredCredits,
    required this.completedCredits,
    this.totalHours = 0,
    List<TrainingPlanCourse>? courses,
  }) : courses = courses ?? [];

  TrainingPlanGroup toGroup() {
    return TrainingPlanGroup(
      name: name,
      requiredCredits: requiredCredits,
      completedCredits: completedCredits,
      totalHours: totalHours,
      courses: List.unmodifiable(courses),
    );
  }
}

bool _isCompletedStatus(String status) {
  return status.contains('\u5df2\u4fee') ||
      status.contains('\u901a\u8fc7') ||
      status.contains('\u514d\u4fee') ||
      status.contains('\u5408\u683c');
}

List<TrainingPlanGroup> parseTrainingPlan(String html) {
  _throwIfSessionExpired(html);
  final tableMatch = RegExp(
    r'''<table[^>]*id=['"]mxh['"][^>]*>(.*?)</table>''',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (tableMatch == null) return [];

  final tableHtml = tableMatch.group(1) ?? '';
  final rowMatches = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(tableHtml);

  final order = <String>[];
  final groups = <String, _TrainingPlanAccumulator>{};
  String? currentName;
  int currentRequired = 0;
  int currentCompleted = 0;

  for (final row in rowMatches) {
    final rowHtml = row.group(1) ?? '';
    if (rowHtml.toLowerCase().contains('<th')) continue;

    final cellMatches = RegExp(
      r'<td[^>]*>(.*?)</td>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(rowHtml);

    final cells = <String>[];
    for (final cell in cellMatches) {
      cells.add(_stripHtml(cell.group(1) ?? ''));
    }

    if (cells.isEmpty) continue;
    if (cells.any(
      (cell) =>
          cell.contains('\u5c0f\u8ba1') || cell.contains('\u5408\u8ba1'),
    )) {
      continue;
    }

    if (cells[0].contains('\u5e94\u4fee') &&
        cells[0].contains('\u5df2\u4fee')) {
      final raw = cells[0];
      final match = RegExp(
        r'^(.*?)\s*\(?\s*\u5e94\u4fee\s*(\d+)\s*/\s*\u5df2\u4fee\s*(\d+)\s*\)?',
      ).firstMatch(raw);
      String name = raw.trim();
      int required = 0;
      int completed = 0;
      if (match != null) {
        name = match.group(1)?.trim() ?? name;
        required = int.tryParse(match.group(2) ?? '') ?? 0;
        completed = int.tryParse(match.group(3) ?? '') ?? 0;
      }
      currentName = name;
      currentRequired = required;
      currentCompleted = completed;

      final existing = groups[name];
      if (existing == null) {
        groups[name] = _TrainingPlanAccumulator(
          name: name,
          requiredCredits: required,
          completedCredits: completed,
          courses: [],
        );
        order.add(name);
      } else {
        existing.requiredCredits = required;
        existing.completedCredits = completed;
      }
    }

    if (currentName == null || currentName.isEmpty) continue;
    if (cells.length < 2) continue;

    final hasGroupCell = cells[0].contains('\u5e94\u4fee') &&
        cells[0].contains('\u5df2\u4fee');
    final base = hasGroupCell ? 0 : -1;
    final codeIndex = 2 + base;
    final nameIndex = 3 + base;
    final statusIndex = 4 + base;
    final attributeIndex = 6 + base;
    final creditIndex = 7 + base;

    if (codeIndex < 0 || nameIndex < 0 || statusIndex < 0) continue;
    if (cells.length <= statusIndex) continue;

    final code = cells[codeIndex].trim();
    final courseName = cells[nameIndex].trim();
    final status = cells[statusIndex].trim();
    final attribute =
        attributeIndex >= 0 && attributeIndex < cells.length
            ? cells[attributeIndex].trim()
            : '';
    final credits =
        creditIndex >= 0 && creditIndex < cells.length
            ? cells[creditIndex].trim()
            : '';
    final term = cells.isNotEmpty ? cells.last.trim() : '';
    if (courseName.isEmpty && code.isEmpty) continue;

    final totalHoursRaw =
        cells.length > 1 ? cells[cells.length - 2].trim() : '';
    final totalHoursText = _extractNumberText(totalHoursRaw);
    final totalHours = _parseInt(totalHoursText);

    final group = groups[currentName];
    if (group != null) {
      if (totalHours != null) {
        group.totalHours += totalHours;
      }
      group.requiredCredits = currentRequired;
      group.completedCredits = currentCompleted;
      group.courses.add(
        TrainingPlanCourse(
          code: code,
          name: courseName.isEmpty ? code : courseName,
          status: status,
          completed: _isCompletedStatus(status),
          attribute: attribute,
          credits: credits,
          term: term,
          totalHours: totalHoursText,
        ),
      );
    }
  }

  return order.map((name) => groups[name]!.toGroup()).toList();
}

String _extractAttribute(String tag, String name) {
  final escaped = RegExp.escape(name);
  final match = RegExp(
    '$escaped\\s*=\\s*([\"\\\'])(.*?)\\1',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(tag);
  return match?.group(2) ?? '';
}

int _findTagEnd(String text, int start) {
  var inSingle = false;
  var inDouble = false;
  for (var i = start; i < text.length; i += 1) {
    final char = text[i];
    if (char == '"' && !inSingle) {
      inDouble = !inDouble;
    } else if (char == "'" && !inDouble) {
      inSingle = !inSingle;
    } else if (char == '>' && !inSingle && !inDouble) {
      return i;
    }
  }
  return -1;
}

List<String> _scheduleLinesFromTitle(String title) {
  if (title.isEmpty) return const [];
  final normalized =
      title.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  final decoded = _decodeHtmlEntities(normalized)
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  return decoded
      .split(RegExp(r'\n+'))
      .map((line) => _stripHtml(line))
      .where((line) => line.isNotEmpty)
      .toList();
}

List<ScheduleItem> parseDailySchedule(String html, int weekdayIndex) {
  _throwIfSessionExpired(html);
  if (weekdayIndex < 1 || weekdayIndex > 7) return [];

  final tableMatch = RegExp(
    r'<table[^>]*kb_table[^>]*>(.*?)</table>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (tableMatch == null) return [];

  final tableHtml = tableMatch.group(1) ?? '';
  final rowMatches = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(tableHtml);

  final items = <ScheduleItem>[];
  for (final row in rowMatches) {
    final rowHtml = row.group(1) ?? '';
    if (rowHtml.contains('<th')) continue;

    final cellMatches = RegExp(
      r'<td[^>]*>(.*?)</td>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(rowHtml);

    final cells = <String>[];
    for (final cell in cellMatches) {
      cells.add(cell.group(1) ?? '');
    }

    if (cells.length <= weekdayIndex) continue;

    final period = _stripHtml(cells[0]);
    final dayCell = cells[weekdayIndex];

    final courseMatches = RegExp(
      r'<p[\s\S]*?</p>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(dayCell);

    for (final course in courseMatches) {
      final block = course.group(0) ?? '';
      final tagEnd = _findTagEnd(block, 2);
      if (tagEnd == -1) continue;
      final tag = block.substring(0, tagEnd + 1);
      final inner = block.substring(tagEnd + 1, block.length - 4);
      final name = _stripHtml(inner);
      if (name.isEmpty) continue;
      final title = _extractAttribute(tag, 'title');
      final detailLines = _scheduleLinesFromTitle(title);
      items.add(
        ScheduleItem(
          period: period,
          courseName: name,
          detailLines: detailLines,
        ),
      );
    }
  }

  return items;
}
