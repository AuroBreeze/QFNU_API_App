class LoginResult {
  final bool ok;
  final String raw;
  final String? alert;

  const LoginResult({required this.ok, required this.raw, this.alert});

  String? get message {
    final value = alert?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String get preview {
    if (raw.isEmpty) return '';
    if (raw.length <= 300) return raw;
    return '${raw.substring(0, 300)}...';
  }
}

class TermOption {
  final String value;
  final String label;
  final bool selected;

  const TermOption({
    required this.value,
    required this.label,
    required this.selected,
  });
}

class ExamItem {
  final String courseCode;
  final String courseName;
  final String teacher;
  final String time;
  final String place;
  final String seat;

  const ExamItem({
    required this.courseCode,
    required this.courseName,
    required this.teacher,
    required this.time,
    required this.place,
    required this.seat,
  });
}
