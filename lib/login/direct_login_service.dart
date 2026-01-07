import 'dart:convert';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/constants.dart';
import 'package:qfnu_app/shared/html_parsers.dart';
import 'package:qfnu_app/shared/http_options.dart';
import 'package:qfnu_app/shared/models.dart';

String? _extractAlert(String raw) {
  final match = RegExp(
    "alert\\((['\"])(.*?)\\1\\)",
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(raw);
  if (match == null) return null;
  var message = match.group(2) ?? '';
  message = message
      .replaceAll(r'\\r', '\\r')
      .replaceAll(r'\\n', '\\n')
      .replaceAll(r'\\t', '\\t')
      .replaceAll(r'\\"', '"')
      .replaceAll(r"\\'", "'");
  message = message.trim();
  return message.isEmpty ? null : message;
}

bool _isLoginSuccess(
  String raw, {
  Uri? finalUri,
  String? locationHeader,
  List<RedirectRecord> redirects = const [],
}) {
  if (raw.contains('xsMain.jsp')) return true;
  final uriValue = finalUri?.toString();
  if (uriValue != null && uriValue.contains('xsMain.jsp')) return true;
  if (locationHeader != null && locationHeader.contains('xsMain.jsp')) {
    return true;
  }
  for (final redirect in redirects) {
    final location = redirect.location.toString();
    if (location.contains('xsMain.jsp')) return true;
  }
  return false;
}

class DirectLoginService implements LoginService {
  final Dio _dio;
  final CookieJar? _cookieJar;
  bool _sessionReady = false;

  DirectLoginService._(this._dio, this._cookieJar);

  static Future<DirectLoginService> create() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.plain,
        followRedirects: true,
        validateStatus: acceptRedirectStatus,
        receiveDataWhenStatusError: true,
        headers: const {
          'User-Agent': browserUserAgent,
        },
      ),
    );

    CookieJar? cookieJar;
    if (!kIsWeb) {
      final directory = await getApplicationSupportDirectory();
      final storagePath = '${directory.path}/cookies';
      cookieJar = PersistCookieJar(storage: FileStorage(storagePath));
      dio.interceptors.add(CookieManager(cookieJar));
    }

    return DirectLoginService._(dio, cookieJar);
  }

  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    await _dio.get(
      mainUrl,
      options: requestOptions(responseType: ResponseType.plain),
    );
    _sessionReady = true;
  }

  @override
  Future<Uint8List> fetchCaptcha() async {
    await _ensureSession();
    final response = await _dio.get(
      captchaUrl,
      options: requestOptions(responseType: ResponseType.bytes),
    );

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
    await _ensureSession();

    final encoded =
        '${base64Encode(utf8.encode(username))}%%%${base64Encode(utf8.encode(password))}';

    final response = await _dio.post(
      loginUrl,
      data: {
        'userAccount': '',
        'userPassword': '',
        'RANDOMCODE': captcha,
        'encoded': encoded,
      },
      options: requestOptions(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    final raw = response.data?.toString() ?? '';
    final alert = _extractAlert(raw);
    final ok = _isLoginSuccess(
      raw,
      finalUri: response.realUri,
      locationHeader: response.headers.value('location'),
      redirects: response.redirects,
    );
    return LoginResult(ok: ok, raw: raw, alert: alert);
  }

  @override
  Future<void> logout() async {
    _sessionReady = false;
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }

  @override
  Future<List<TermOption>> fetchExamTerms() async {
    await _ensureSession();
    final response = await _dio.get(
      queryUrl,
      options: requestOptions(responseType: ResponseType.plain),
    );
    final html = response.data?.toString() ?? '';
    return parseTermOptions(html);
  }

  @override
  Future<List<ExamItem>> fetchExamList({required String xnxqid}) async {
    await _ensureSession();
    final response = await _dio.post(
      listUrl,
      data: {
        'xqlbmc': '',
        'sxxnxq': '',
        'dqxnxq': '',
        'ckbz': '',
        'xnxqid': xnxqid,
        'xqlb': '',
      },
      options: requestOptions(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );
    final html = response.data?.toString() ?? '';
    return parseExamList(html);
  }

  @override
  Future<GradeQueryOptions> fetchGradeQueryOptions() async {
    await _ensureSession();
    final response = await _dio.get(
      gradeQueryUrl,
      options: requestOptions(responseType: ResponseType.plain),
    );
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
    await _ensureSession();
    final response = await _dio.post(
      gradeListUrl,
      data: {
        'kksj': kksj,
        'kcxz': kcxz,
        'kcmc': kcmc,
        'xsfs': xsfs,
      },
      options: requestOptions(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );
    final html = response.data?.toString() ?? '';
    return parseGradeList(html);
  }
}
