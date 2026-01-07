import 'dart:typed_data';

import 'package:qfnu_app/shared/models.dart';

abstract class LoginService {
  Future<Uint8List> fetchCaptcha();
  Future<LoginResult> login({
    required String username,
    required String password,
    required String captcha,
  });
  Future<List<TermOption>> fetchExamTerms();
  Future<List<ExamItem>> fetchExamList({required String xnxqid});
  Future<GradeQueryOptions> fetchGradeQueryOptions();
  Future<List<GradeItem>> fetchGrades({
    String kksj,
    String kcxz,
    String kcmc,
    String xsfs,
  });
}
