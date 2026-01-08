import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qfnu_app/login/direct_login_service.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/shared/constants.dart';

class CloudPushService {
  CloudPushService._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Content-Type': 'application/json',
      },
    ),
  );

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!_isSupportedPlatform()) return;
    await Firebase.initializeApp();
    await _ensureNotificationChannels();
    _initialized = true;
  }

  static Future<NotificationSettings> requestPermission() async {
    if (!_isSupportedPlatform()) {
      throw Exception('Cloud notifications are not supported on this platform.');
    }
    await ensureInitialized();
    return FirebaseMessaging.instance.requestPermission();
  }

  static Future<String?> getToken() async {
    if (!_isSupportedPlatform()) return null;
    await ensureInitialized();
    return FirebaseMessaging.instance.getToken();
  }

  static Future<void> registerSession({
    required LoginService service,
    required String username,
  }) async {
    if (kIsWeb) {
      throw Exception('Cloud notifications are not supported on web.');
    }
    if (!_isSupportedPlatform()) {
      throw Exception('Cloud notifications are not supported on this platform.');
    }
    await ensureInitialized();
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('FCM token unavailable');
    }

    final cookies = await _extractCookies(service);
    if (cookies.isEmpty) {
      throw Exception('Session cookies unavailable');
    }

    if (firebaseFunctionsBaseUrl.contains('<project-id>')) {
      throw Exception('Firebase functions URL not configured');
    }

    await _dio.post(
      '$firebaseFunctionsBaseUrl/registerSession',
      data: {
        'username': username,
        'token': token,
        'cookies': cookies,
        'platform': _platformLabel(),
      },
    );
  }

  static Future<void> unregisterToken() async {
    if (kIsWeb) return;
    if (!_isSupportedPlatform()) return;
    await ensureInitialized();
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    if (firebaseFunctionsBaseUrl.contains('<project-id>')) {
      return;
    }
    await _dio.post(
      '$firebaseFunctionsBaseUrl/unregisterToken',
      data: {
        'token': token,
      },
    );
  }

  static Future<List<String>> _extractCookies(LoginService service) async {
    if (service is DirectLoginService) {
      return service.exportCookies();
    }
    return const [];
  }

  static Future<void> _ensureNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final plugin = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(initializationSettings);
    final android =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'grade_updates',
        'Grade updates',
        description: 'Cloud grade update notifications',
        importance: Importance.high,
      ),
    );
  }

  static String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
