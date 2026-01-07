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

class ScheduleItem {
  final String period;
  final String courseName;
  final List<String> detailLines;

  const ScheduleItem({
    required this.period,
    required this.courseName,
    required this.detailLines,
  });
}

class TrainingPlanGroup {
  final String name;
  final int requiredCredits;
  final int completedCredits;
  final int totalHours;
  final List<TrainingPlanCourse> courses;

  const TrainingPlanGroup({
    required this.name,
    required this.requiredCredits,
    required this.completedCredits,
    required this.totalHours,
    required this.courses,
  });

  double? get progress {
    if (requiredCredits <= 0) return null;
    return completedCredits / requiredCredits;
  }
}

class TrainingPlanCourse {
  final String code;
  final String name;
  final String status;
  final bool completed;
  final String attribute;
  final String credits;
  final String term;
  final String totalHours;

  const TrainingPlanCourse({
    required this.code,
    required this.name,
    required this.status,
    required this.completed,
    required this.attribute,
    required this.credits,
    required this.term,
    required this.totalHours,
  });
}
