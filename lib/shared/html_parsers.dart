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

List<TermOption> parseSelectOptions(
  String html,
  String selectId, {
  bool includeEmpty = false,
}) {
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
