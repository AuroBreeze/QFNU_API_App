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

List<TermOption> parseTermOptions(String html) {
  final selectMatch = RegExp(
    r'<select[^>]*id="xnxqid"[^>]*>(.*?)</select>',
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
    if (value.isEmpty) continue;
    options.add(
      TermOption(
        value: value,
        label: label.isEmpty ? value : label,
        selected: selected,
      ),
    );
  }

  return options;
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
