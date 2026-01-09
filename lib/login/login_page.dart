import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:qfnu_app/l10n/app_localizations.dart';
import 'package:qfnu_app/home/home_page.dart';
import 'package:qfnu_app/login/direct_login_service.dart';
import 'package:qfnu_app/login/login_service.dart';
import 'package:qfnu_app/login/proxy_login_service.dart';
import 'package:qfnu_app/shared/constants.dart';
import 'package:qfnu_app/shared/html_parsers.dart';
import 'package:qfnu_app/settings/tribute_page.dart';
import 'package:qfnu_app/shared/settings_store.dart';
import 'package:qfnu_app/shared/widgets/glow_circle.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _proxyController = TextEditingController(text: defaultProxyUrl);
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _captchaController = TextEditingController();
  LoginService? _service;
  Future<LoginService>? _serviceFuture;
  String? _serviceKey;
  Uint8List? _captchaBytes;
  bool _captchaLoading = false;
  bool _loading = false;
  bool _restoringSession = false;
  bool _rememberAccount = false;
  bool _rememberPassword = false;
  bool _showPassword = false;
  String? _error;

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _prefRememberAccount = 'remember_account';
  static const _prefRememberPassword = 'remember_password';
  static const _prefUsername = 'remembered_username';
  static const _securePassword = 'remembered_password';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _proxyController.dispose();
    _userController.dispose();
    _passController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadSavedCredentials();
    final restored = await _tryRestoreSession();
    if (!restored) {
      await _refreshCaptcha();
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_securePassword);
    final rememberAccount = prefs.getBool(_prefRememberAccount) ?? false;
    final rememberPassword = prefs.getBool(_prefRememberPassword) ?? false;
    final savedUsername = prefs.getString(_prefUsername) ?? '';
    final savedPassword = rememberPassword && rememberAccount
        ? await _secureStorage.read(key: _securePassword) ?? ''
        : '';

    if (rememberAccount) {
      _userController.text = savedUsername;
    } else {
      _userController.clear();
    }
    if (rememberPassword && rememberAccount) {
      _passController.text = savedPassword;
    } else {
      _passController.clear();
    }

    if (!mounted) return;
    setState(() {
      _rememberAccount = rememberAccount;
      _rememberPassword = rememberPassword && rememberAccount;
    });
  }

  Future<void> _persistCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_securePassword);
    if (_rememberAccount) {
      await prefs.setBool(_prefRememberAccount, true);
      await prefs.setString(_prefUsername, _userController.text.trim());
    } else {
      await prefs.setBool(_prefRememberAccount, false);
      await prefs.remove(_prefUsername);
    }

    if (_rememberPassword && _rememberAccount) {
      await prefs.setBool(_prefRememberPassword, true);
      await _secureStorage.write(
        key: _securePassword,
        value: _passController.text,
      );
    } else {
      await prefs.setBool(_prefRememberPassword, false);
      await _secureStorage.delete(key: _securePassword);
    }
  }

  void _toggleRememberAccount(bool? value) {
    final enabled = value ?? false;
    setState(() {
      _rememberAccount = enabled;
      if (!enabled) {
        _rememberPassword = false;
      }
    });
    _persistCredentials();
  }

  void _toggleRememberPassword(bool? value) {
    final enabled = value ?? false;
    setState(() {
      _rememberPassword = enabled;
      if (enabled) {
        _rememberAccount = true;
      }
    });
    _persistCredentials();
  }

  Future<bool> _tryRestoreSession() async {
    if (kIsWeb) return false;

    setState(() {
      _restoringSession = true;
    });

    try {
      final service = await _resolveService();
      final terms = await service.fetchExamTerms();
      if (!mounted) return false;
      if (terms.isNotEmpty) {
        final shouldShowTribute = await _shouldShowTributePrompt();
        if (shouldShowTribute && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TributePage(showContinueButton: true),
            ),
          );
          await SettingsStore.setTributePromptShown(true);
        }
        if (!mounted) return false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(
              service: service,
              username: '',
            ),
          ),
        );
        return true;
      }
    } catch (_) {
      // Ignore and fall back to login UI.
    } finally {
      if (mounted) {
        setState(() {
          _restoringSession = false;
        });
      }
    }

    return false;
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.replaceAll(RegExp(r'/+$'), '');
    }
    return trimmed;
  }

  String _proxyUrlRequiredMessage() {
    final l10n = AppLocalizations.of(context);
    return l10n?.proxyUrlRequired ??
        'Proxy URL is required for web testing.';
  }

  Future<LoginService> _resolveService() async {
    if (!kIsWeb) {
      _serviceFuture ??= DirectLoginService.create();
      _service ??= await _serviceFuture!;
      return _service!;
    }

    final baseUrl = _normalizeBaseUrl(_proxyController.text);
    if (baseUrl.isEmpty) {
      throw Exception(_proxyUrlRequiredMessage());
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
      final service = await _resolveService();
      final bytes = await service.fetchCaptcha();
      if (!mounted) return;
      setState(() {
        _captchaBytes = bytes;
      });
      _captchaController.clear();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _captchaBytes = null;
        _error = l10n.loadCaptchaFailed(error.toString());
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
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.fillCredentialsError;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _persistCredentials();
      final service = await _resolveService();
      final result = await service.login(
        username: username,
        password: password,
        captcha: captcha,
      );

      if (!mounted) return;

      if (result.ok) {
        final shouldShowTribute = await _shouldShowTributePrompt();
        if (shouldShowTribute && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TributePage(showContinueButton: true),
            ),
          );
          await SettingsStore.setTributePromptShown(true);
        }
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomePage(
              service: service,
              username: username,
            ),
          ),
        );
      } else {
        final message = result.message;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = message ??
              (looksLikeLoginPage(result.raw)
                  ? l10n.loginFailed
                  : (result.preview.isEmpty
                      ? l10n.loginFailed
                      : result.preview));
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

  Future<bool> _shouldShowTributePrompt() async {
    final enabled = await SettingsStore.getTributePromptEnabled();
    if (!enabled) return false;
    final shown = await SettingsStore.getTributePromptShown();
    return !shown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          const GlowCircle(
            offset: Offset(-120, -100),
            size: 240,
            colors: [Color(0xFFBFE4D8), Color(0xFFECF6F2)],
          ),
          const GlowCircle(
            offset: Offset(180, 80),
            size: 160,
            colors: [Color(0xFFF3DCCB), Color(0xFFF7F1EA)],
          ),
          const GlowCircle(
            offset: Offset(-80, 520),
            size: 200,
            colors: [Color(0xFFCAE5F4), Color(0xFFE9F4FB)],
          ),
          SafeArea(
            child: IgnorePointer(
              ignoring: _restoringSession,
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
                            l10n.loginTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.loginSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 22),
                          if (kIsWeb) ...[
                            Text(
                              l10n.proxyUrlLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _proxyController,
                              decoration: InputDecoration(
                                hintText: l10n.proxyUrlHint,
                                prefixIcon: const Icon(Icons.hub_outlined),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: _userController,
                            decoration: InputDecoration(
                              labelText: l10n.usernameLabel,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passController,
                            decoration: InputDecoration(
                              labelText: l10n.passwordLabel,
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
                                tooltip: _showPassword
                                    ? l10n.hidePassword
                                    : l10n.showPassword,
                              ),
                            ),
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              InkWell(
                                onTap: () => _toggleRememberAccount(
                                  !_rememberAccount,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _rememberAccount,
                                      onChanged: _toggleRememberAccount,
                                    ),
                                    Text(l10n.rememberAccount),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: _rememberAccount
                                    ? () => _toggleRememberPassword(
                                          !_rememberPassword,
                                        )
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _rememberPassword,
                                      onChanged: _rememberAccount
                                          ? _toggleRememberPassword
                                          : null,
                                    ),
                                    Text(
                                      l10n.rememberPassword,
                                      style: TextStyle(
                                        color: _rememberAccount
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                l10n.captchaLabel,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed:
                                    _captchaLoading ? null : _refreshCaptcha,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.refresh),
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
                                    ? Text(l10n.captchaHint)
                                    : Image.memory(
                                        _captchaBytes!,
                                        fit: BoxFit.contain,
                                      ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _captchaController,
                            decoration: InputDecoration(
                              labelText: l10n.captchaLabel,
                              prefixIcon: const Icon(Icons.verified_outlined),
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
                                    : Text(
                                        l10n.loginButton,
                                        style: const TextStyle(
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
          ),
          if (_restoringSession)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.65),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.checkingSession,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
