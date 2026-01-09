import 'dart:typed_data';

import 'package:qfnu_app/shared/models.dart';

abstract class LoginService {
  Future<Uint8List> fetchCaptcha();
  Future<LoginResult> login({
    required String username,
    required String password,
    required String captcha,
  });
  Future<void> logout();
  Future<List<ScheduleItem>> fetchDailySchedule({required DateTime date});
  Future<List<TrainingPlanGroup>> fetchTrainingPlan();
  Future<List<TermOption>> fetchExamTerms();
  Future<List<ExamItem>> fetchExamList({required String xnxqid});
  Future<GradeQueryOptions> fetchGradeQueryOptions();
  Future<List<GradeItem>> fetchGrades({
    String kksj,
    String kcxz,
    String kcmc,
    String xsfs,
  });
  Future<AcademicWarningResult> fetchAcademicWarnings();
  Future<WeekInfo?> fetchCurrentWeekInfo();
  Future<ClassroomQueryOptions> fetchClassroomQueryOptions();
  Future<ClassroomTable> fetchClassroomTable({
    required String xnxqh,
    required String kbjcmsid,
    required String skyx,
    required String xqid,
    required String jzwid,
    required String skjsid,
    required String skjs,
    required String zc1,
    required String zc2,
    required String skxq1,
    required String skxq2,
    required String jc1,
    required String jc2,
  });
}
