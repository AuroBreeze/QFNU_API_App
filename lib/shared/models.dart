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

class GradeQueryOptions {
  final List<TermOption> terms;
  final List<TermOption> courseTypes;
  final List<TermOption> displayModes;

  const GradeQueryOptions({
    required this.terms,
    required this.courseTypes,
    required this.displayModes,
  });
}

class GradeItem {
  final String term;
  final String courseCode;
  final String courseName;
  final String groupName;
  final String score;
  final String scoreFlag;
  final String credit;
  final String hours;
  final String gradePoint;
  final String retakeTerm;
  final String assessmentMethod;
  final String examNature;
  final String courseAttribute;
  final String courseNature;
  final String courseCategory;

  const GradeItem({
    required this.term,
    required this.courseCode,
    required this.courseName,
    required this.groupName,
    required this.score,
    required this.scoreFlag,
    required this.credit,
    required this.hours,
    required this.gradePoint,
    required this.retakeTerm,
    required this.assessmentMethod,
    required this.examNature,
    required this.courseAttribute,
    required this.courseNature,
    required this.courseCategory,
  });
}
