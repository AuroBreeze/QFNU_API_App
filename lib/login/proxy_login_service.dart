import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/html_parsers.dart';
import 'package:qfnu_app/shared/http_options.dart';
import 'package:qfnu_app/shared/models.dart';
import 'package:qfnu_app/shared/training_plan_cache.dart';

class ProxyLoginService implements LoginService {
  final Dio _dio;
  final String baseUrl;
  String? _sessionId;

  ProxyLoginService({required this.baseUrl})
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.plain,
            validateStatus: acceptRedirectStatus,
            receiveDataWhenStatusError: true,
          ),
        );

  Map<String, dynamic> _decodeJson(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw Exception('Invalid response');
  }

  Future<void> _ensureSession() async {
    if (_sessionId != null) return;
    final response = await _dio.get(
      '$baseUrl/session',
      options: requestOptions(responseType: ResponseType.json),
    );
    final payload = _decodeJson(response.data);
    final sessionId = payload['sessionId']?.toString();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('Invalid session response');
    }
    _sessionId = sessionId;
  }

  void _resetSession() {
    _sessionId = null;
  }

  bool _isSessionExpired(DioException error) {
    if (error.response?.statusCode != 404) return false;
    final data = error.response?.data;
    if (data is Map) {
      return data['error']?.toString() == 'Session expired';
    }
    if (data is String) {
      return data.contains('Session expired');
    }
    return false;
  }

  Future<T> _withSessionRetry<T>(Future<T> Function() action) async {
    await _ensureSession();
    try {
      return await action();
    } on DioException catch (error) {
      if (_isSessionExpired(error)) {
        _resetSession();
        await _ensureSession();
        return await action();
      }
      rethrow;
    }
  }

  @override
  Future<Uint8List> fetchCaptcha() async {
    final response = await _withSessionRetry(() {
      return _dio.get(
        '$baseUrl/captcha',
        queryParameters: {'sid': _sessionId},
        options: requestOptions(responseType: ResponseType.bytes),
      );
    });

    final data = response.data;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);

    throw Exception('Unexpected captcha response');
  }

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
    required String captcha,
  }) async {
    final response = await _withSessionRetry(() {
      return _dio.post(
        '$baseUrl/login',
        data: {
          'sessionId': _sessionId,
          'username': username,
          'password': password,
          'captcha': captcha,
        },
        options: requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
    });

    final payload = _decodeJson(response.data);
    final ok = payload['ok'] == true;
    final raw = payload['raw']?.toString() ?? '';
    final loginError = parseLoginErrorMessage(raw);
    final alert = loginError ??
        (looksLikeLoginPage(raw) ? null : payload['alert']?.toString());
    return LoginResult(ok: ok, raw: raw, alert: alert);
  }

  @override
  Future<void> logout() async {
    _resetSession();
  }

  @override
  Future<List<ScheduleItem>> fetchDailySchedule({required DateTime date}) async {
    final response = await _withSessionRetry(() {
      return _dio.post(
        '$baseUrl/kb/day',
        data: {
          'sessionId': _sessionId,
          'rq': '${date.year.toString().padLeft(4, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}',
        },
        options: requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    });

    final html = response.data?.toString() ?? '';
    return parseDailySchedule(html, date.weekday);
  }

  @override
  Future<List<TrainingPlanGroup>> fetchTrainingPlan() async {
    final cachedHtml = await TrainingPlanCache.getFreshHtml();
    if (cachedHtml != null) {
      return parseTrainingPlan(cachedHtml);
    }

    final response = await _withSessionRetry(() {
      return _dio.get(
        '$baseUrl/pyfa',
        queryParameters: {'sid': _sessionId},
        options: requestOptions(responseType: ResponseType.plain),
      );
    });
    final html = response.data?.toString() ?? '';
    final groups = parseTrainingPlan(html);
    await TrainingPlanCache.write(html);
    return groups;
  }

  @override
  Future<List<TermOption>> fetchExamTerms() async {
    final response = await _withSessionRetry(() {
      return _dio.get(
        '$baseUrl/xsks/query',
        queryParameters: {'sid': _sessionId},
        options: requestOptions(responseType: ResponseType.plain),
      );
    });
    final html = response.data?.toString() ?? '';
    return parseTermOptions(html);
  }

  @override
  Future<List<ExamItem>> fetchExamList({required String xnxqid}) async {
    final response = await _withSessionRetry(() {
      return _dio.post(
        '$baseUrl/xsks/list',
        data: {
          'sessionId': _sessionId,
          'xnxqid': xnxqid,
        },
        options: requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    });
    final html = response.data?.toString() ?? '';
    return parseExamList(html);
  }

  @override
  Future<GradeQueryOptions> fetchGradeQueryOptions() async {
    final response = await _withSessionRetry(() {
      return _dio.get(
        '$baseUrl/kscj/query',
        queryParameters: {'sid': _sessionId},
        options: requestOptions(responseType: ResponseType.plain),
      );
    });
    final html = response.data?.toString() ?? '';
    return parseGradeQueryOptions(html);
  }

  @override
  Future<List<GradeItem>> fetchGrades({
    String kksj = '',
    String kcxz = '',
    String kcmc = '',
    String xsfs = 'all',
  }) async {
    final response = await _withSessionRetry(() {
      return _dio.post(
        '$baseUrl/kscj/list',
        data: {
          'sessionId': _sessionId,
          'kksj': kksj,
          'kcxz': kcxz,
          'kcmc': kcmc,
          'xsfs': xsfs,
        },
        options: requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    });
    final html = response.data?.toString() ?? '';
    return parseGradeList(html);
  }
}
