import 'dart:convert';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

const _baseUrl = 'http://zhjw.qfnu.edu.cn';
const _mainUrl = '$_baseUrl/jsxsd/framework/xsMain.jsp';
const _captchaUrl = '$_baseUrl/jsxsd/verifycode.servlet';
const _loginUrl = '$_baseUrl/jsxsd/xk/LoginToXkLdap';
const _queryUrl = '$_baseUrl/jsxsd/xsks/xsksap_query';
const _listUrl = '$_baseUrl/jsxsd/xsks/xsksap_list';
const _defaultProxyUrl = 'http://localhost:8080';
const _browserUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

bool _acceptRedirectStatus(int? status) => status != null && status < 400;

Options _requestOptions({
  ResponseType? responseType,
  String? contentType,
}) {
  return Options(
    responseType: responseType,
    contentType: contentType,
    validateStatus: _acceptRedirectStatus,
    receiveDataWhenStatusError: true,
  );
}

void main() {
  runApp(const QfnuApp());
}

class QfnuApp extends StatelessWidget {
  const QfnuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF145A52),
    );

    return MaterialApp(
      title: 'QFNU MVP',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.94),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

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

List<TermOption> _parseTermOptions(String html) {
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

List<ExamItem> _parseExamList(String html) {
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

abstract class LoginService {
  Future<Uint8List> fetchCaptcha();
  Future<LoginResult> login({
    required String username,
    required String password,
    required String captcha,
  });
  Future<List<TermOption>> fetchExamTerms();
  Future<List<ExamItem>> fetchExamList({required String xnxqid});
}

class DirectLoginService implements LoginService {
  final Dio _dio;
  bool _sessionReady = false;

  DirectLoginService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.plain,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 400,
            receiveDataWhenStatusError: true,
            headers: const {
              'User-Agent': _browserUserAgent,
            },
          ),
        ) {
    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(CookieJar()));
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    await _dio.get(
      _mainUrl,
      options: _requestOptions(responseType: ResponseType.plain),
    );
    _sessionReady = true;
  }

  @override
  Future<Uint8List> fetchCaptcha() async {
    await _ensureSession();
    final response = await _dio.get(
      _captchaUrl,
      options: _requestOptions(responseType: ResponseType.bytes),
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
      _loginUrl,
      data: {
        'userAccount': '',
        'userPassword': '',
        'RANDOMCODE': captcha,
        'encoded': encoded,
      },
      options: _requestOptions(
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
  Future<List<TermOption>> fetchExamTerms() async {
    await _ensureSession();
    final response = await _dio.get(
      _queryUrl,
      options: _requestOptions(responseType: ResponseType.plain),
    );
    final html = response.data?.toString() ?? '';
    return _parseTermOptions(html);
  }

  @override
  Future<List<ExamItem>> fetchExamList({required String xnxqid}) async {
    await _ensureSession();
    final response = await _dio.post(
      _listUrl,
      data: {
        'xqlbmc': '',
        'sxxnxq': '',
        'dqxnxq': '',
        'ckbz': '',
        'xnxqid': xnxqid,
        'xqlb': '',
      },
      options: _requestOptions(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );
    final html = response.data?.toString() ?? '';
    return _parseExamList(html);
  }
}

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
      options: _requestOptions(responseType: ResponseType.json),
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
        options: _requestOptions(responseType: ResponseType.bytes),
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
        options: _requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
    });

    final payload = _decodeJson(response.data);
    final ok = payload['ok'] == true;
    final raw = payload['raw']?.toString() ?? '';
    final alert = payload['alert']?.toString();
    return LoginResult(ok: ok, raw: raw, alert: alert);
  }

  @override
  Future<List<TermOption>> fetchExamTerms() async {
    final response = await _withSessionRetry(() {
      return _dio.get(
        '$baseUrl/xsks/query',
        queryParameters: {'sid': _sessionId},
        options: _requestOptions(responseType: ResponseType.plain),
      );
    });
    final html = response.data?.toString() ?? '';
    return _parseTermOptions(html);
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
        options: _requestOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    });
    final html = response.data?.toString() ?? '';
    return _parseExamList(html);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _proxyController = TextEditingController(text: _defaultProxyUrl);
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _captchaController = TextEditingController();
  LoginService? _service;
  String? _serviceKey;
  Uint8List? _captchaBytes;
  bool _captchaLoading = false;
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshCaptcha();
  }

  @override
  void dispose() {
    _proxyController.dispose();
    _userController.dispose();
    _passController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.replaceAll(RegExp(r'/+$'), '');
    }
    return trimmed;
  }

  LoginService _resolveService() {
    if (!kIsWeb) {
      _service ??= DirectLoginService();
      return _service!;
    }

    final baseUrl = _normalizeBaseUrl(_proxyController.text);
    if (baseUrl.isEmpty) {
      throw Exception('Proxy URL is required for web testing.');
    }

    final key = 'proxy:$baseUrl';
    if (_service == null || _serviceKey != key) {
      _service = ProxyLoginService(baseUrl: baseUrl);
      _serviceKey = key;
    }

    return _service!;
  }

  Future<void> _refreshCaptcha({bool clearError = true}) async {
    if (_captchaLoading) return;

    setState(() {
      _captchaLoading = true;
      if (clearError) {
        _error = null;
      }
    });

    try {
      final service = _resolveService();
      final bytes = await service.fetchCaptcha();
      if (!mounted) return;
      setState(() {
        _captchaBytes = bytes;
      });
      _captchaController.clear();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _captchaBytes = null;
        _error = 'Failed to load captcha: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _captchaLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final username = _userController.text.trim();
    final password = _passController.text;
    final captcha = _captchaController.text.trim();

    if (username.isEmpty || password.isEmpty || captcha.isEmpty) {
      setState(() {
        _error = 'Please fill in username, password, and captcha.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = _resolveService();
      final result = await service.login(
        username: username,
        password: password,
        captcha: captcha,
      );

      if (!mounted) return;

      if (result.ok) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExamSchedulePage(
              service: service,
              username: username,
            ),
          ),
        );
      } else {
        final message = result.message;
        setState(() {
          _error = message ??
              (result.preview.isEmpty ? 'Login failed.' : result.preview);
        });
        await _refreshCaptcha(clearError: false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5EFE6),
                  Color(0xFFE3F1EC),
                  Color(0xFFF1E9DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const _GlowCircle(
            offset: Offset(-120, -100),
            size: 240,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const _GlowCircle(
            offset: Offset(180, 80),
            size: 160,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          const _GlowCircle(
            offset: Offset(-80, 520),
            size: 200,
            colors: [Color(0xFFCAE5F4), Color(0xFFE9F4FB)],
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black26,
                    color: Colors.white.withOpacity(0.92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'QFNU Portal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to access your academic services.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (kIsWeb) ...[
                            Text(
                              'Proxy URL (Web only)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _proxyController,
                              decoration: const InputDecoration(
                                hintText: _defaultProxyUrl,
                                prefixIcon: Icon(Icons.hub_outlined),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: _userController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                tooltip:
                                    _showPassword ? 'Hide password' : 'Show password',
                              ),
                            ),
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                'Captcha',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed:
                                    _captchaLoading ? null : _refreshCaptcha,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 76,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: _captchaLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : _captchaBytes == null
                                    ? const Text('Tap refresh to load')
                                    : Image.memory(
                                        _captchaBytes!,
                                        fit: BoxFit.contain,
                                      ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _captchaController,
                            decoration: const InputDecoration(
                              labelText: 'Captcha',
                              prefixIcon: Icon(Icons.verified_outlined),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _loading ? null : _submit(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primaryContainer,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _error == null
                                ? const SizedBox.shrink()
                                : Container(
                                    key: ValueKey(_error),
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error
                                          .withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.error
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: theme.colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExamSchedulePage extends StatefulWidget {
  final LoginService service;
  final String username;

  const ExamSchedulePage({
    super.key,
    required this.service,
    required this.username,
  });

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  List<TermOption> _terms = [];
  String? _selectedTerm;
  List<ExamItem> _items = [];
  bool _loadingTerms = false;
  bool _loadingList = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _loadingTerms = true;
      _error = null;
    });

    try {
      final terms = await widget.service.fetchExamTerms();
      if (!mounted) return;

      if (terms.isEmpty) {
        setState(() {
          _terms = [];
          _selectedTerm = null;
          _error = 'No term options found.';
        });
        return;
      }

      String? defaultValue;
      for (final term in terms) {
        if (term.selected) {
          defaultValue = term.value;
          break;
        }
      }
      if (defaultValue == null) {
        if (terms.length > 1) {
          defaultValue = terms[1].value;
        } else if (terms.isNotEmpty) {
          defaultValue = terms.first.value;
        }
      }

      setState(() {
        _terms = terms;
        _selectedTerm = defaultValue;
      });

      if (defaultValue != null) {
        await _loadList(defaultValue);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load terms: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingTerms = false;
        });
      }
    }
  }

  Future<void> _loadList(String term) async {
    setState(() {
      _loadingList = true;
      _error = null;
    });

    try {
      final items = await widget.service.fetchExamList(xnxqid: term);
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load exams: $error';
        _items = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingList = false;
        });
      }
    }
  }

  Widget _buildExamCard(ExamItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName.isEmpty ? 'Untitled course' : item.courseName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.courseCode} \u2022 ${item.teacher}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item.time)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item.place)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_seat_outlined, size: 16),
              const SizedBox(width: 8),
              Text(item.seat.isEmpty ? '-' : item.seat),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F1EA),
                  Color(0xFFE6F3EE),
                  Color(0xFFF1E9DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const _GlowCircle(
            offset: Offset(-140, -120),
            size: 220,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const _GlowCircle(
            offset: Offset(200, 120),
            size: 180,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.username}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingTerms)
                    const LinearProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedTerm,
                            items: _terms
                                .map(
                                  (term) => DropdownMenuItem(
                                    value: term.value,
                                    child: Text(term.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTerm = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Term',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _selectedTerm == null || _loadingList
                                ? null
                                : () => _loadList(_selectedTerm!),
                            icon: const Icon(Icons.search),
                            label: const Text('Query'),
                          ),
                        ),
                      ],
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loadingList
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? Center(
                                child: Text(
                                  'No exam data available.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            : ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _buildExamCard(item, theme);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Offset offset;
  final double size;
  final List<Color> colors;

  const _GlowCircle({
    required this.offset,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
