import 'dart:convert';
import 'package:flutter/foundation.dart'; // compute, kDebugMode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../navigation/app_navigation.dart';
import '../services/biometric_quick_login_storage.dart';
import 'create_account.dart';

class LoginScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final VoidCallback onToggleTheme;

  const LoginScreen({
    super.key,
    required this.themeNotifier,
    required this.onToggleTheme,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _localAuth = LocalAuthentication();
  bool _didAttemptAutoBiometric = false;

  bool _obscure = true;
  bool _busy = false;
  String _status = '';

  static const _formulasUrl =
      'https://raw.githubusercontent.com/danisiaj/baby_formula_recipes/main/formulas.json';
  static const _additivesUrl =
      'https://raw.githubusercontent.com/danisiaj/baby_formula_recipes/main/additives.json';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Emulator/debug sessions can stall when auto biometric triggers at startup.
      // Keep manual biometric available via the button.
      if (kDebugMode) return;
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _tryAutoBiometricOnOpen();
      });
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ---------- JSON helpers ----------

  static Map<String, dynamic> _parseJsonToMap(String s) {
    final decoded = json.decode(s);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    throw Exception('JSON root is not an object');
  }

  Future<Map<String, dynamic>> _loadAssetJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return compute(_parseJsonToMap, raw);
  }

  Future<Map<String, dynamic>> _loadFromHttpWithFallback({
    required String url,
    required Map<String, dynamic> fallback,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(timeout);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final body = res.body.trim();
      if (body.isEmpty) throw Exception('Empty response');
      return compute(_parseJsonToMap, body);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HTTP FAILED for "$url": $e');
        debugPrint('Falling back to LOCAL assets.');
      }
      return fallback;
    }
  }

  Future<void> _loadDataAndNavigate() async {
    setState(() => _status = 'Loading local data...');

    final localFormulas = await _loadAssetJson('assets/formulas.json');
    final localAdditives = await _loadAssetJson('assets/additives.json');

    setState(() => _status = 'Loading formulas...');
    final formulas = await _loadFromHttpWithFallback(
      url: _formulasUrl,
      fallback: localFormulas,
    );

    setState(() => _status = 'Loading additives...');
    final additives = await _loadFromHttpWithFallback(
      url: _additivesUrl,
      fallback: localAdditives,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppNavigation(
          isDarkMode: widget.themeNotifier.value == ThemeMode.dark,
          onToggleTheme: widget.onToggleTheme,
          preloadedFormulas: formulas,
          preloadedAdditives: additives,
          themeNotifier: widget.themeNotifier,
        ),
      ),
    );
  }

  Future<void> _tryAutoBiometricOnOpen() async {
    if (!mounted || _busy || _didAttemptAutoBiometric) return;
    _didAttemptAutoBiometric = true;

    final enabled = await BiometricQuickLoginStorage.isEnabled();
    if (!enabled) return;

    final hasCreds = await BiometricQuickLoginStorage.hasCredentials();
    final hasSession = FirebaseAuth.instance.currentUser != null;
    if (!hasCreds && !hasSession) return;

    if (!mounted) return;
    await _onBiometricPressed(isAutoPrompt: true);
  }

  Future<bool> _canUseBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return canCheck && isSupported;
  }

  Future<String> _biometricPromptReason() async {
    final available = await _localAuth.getAvailableBiometrics();
    if (available.contains(BiometricType.face)) {
      return 'Unlock with face';
    }
    if (available.contains(BiometricType.fingerprint)) {
      return 'Unlock with fingerprint';
    }
    return 'Unlock';
  }

  Future<bool> _isBiometricQuickLoginEnabled() async {
    return BiometricQuickLoginStorage.isEnabled();
  }

  Future<void> _saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await BiometricQuickLoginStorage.saveCredentialsOnly(
      email: email,
      password: password,
    );
    await BiometricQuickLoginStorage.setEnabled(true);
  }

  Future<void> _clearBiometricCredentials() async {
    await BiometricQuickLoginStorage.clearAll();
  }

  Future<Map<String, String>?> _readBiometricCredentials() async {
    return BiometricQuickLoginStorage.readCredentials();
  }

  Future<void> _maybeOfferBiometricEnrollment({
    required String email,
    required String password,
  }) async {
    if (!await _canUseBiometrics()) return;

    if (await _isBiometricQuickLoginEnabled()) {
      // Keep stored credentials fresh if password changed.
      await _saveBiometricCredentials(email: email, password: password);
      return;
    }

    if (!mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Enable biometric login?'),
          content: const Text(
            'Use Face ID or fingerprint for future logins on this device.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E88E5),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (enable == true) {
      await _saveBiometricCredentials(email: email, password: password);
    }
  }

  Future<void> _migrateLegacyUserPath(User user) async {
    try {
      final db = FirebaseDatabase.instance;
      final legacyRef = db.ref('user/${user.uid}');
      final legacySnap = await legacyRef.get();
      if (!legacySnap.exists) return;
      final legacyVal = legacySnap.value;
      if (legacyVal is! Map) {
        await legacyRef.remove();
        return;
      }

      final currentRef = db.ref('users/${user.uid}');
      final currentSnap = await currentRef.get();

      final updates = <String, Object?>{};

      if (legacyVal['favorites'] is Map) {
        final legacyFavorites = Map<String, dynamic>.from(
          legacyVal['favorites'] as Map,
        );
        final currentFavSnap = await currentRef.child('favorites').get();
        final currentFavorites = currentFavSnap.value is Map
            ? Map<String, dynamic>.from(currentFavSnap.value as Map)
            : <String, dynamic>{};
        updates['users/${user.uid}/favorites'] = {
          ...legacyFavorites,
          ...currentFavorites,
        };
      }

      for (final key in ['username', 'email', 'role', 'createdAt']) {
        if (legacyVal[key] != null) {
          final currentVal = (currentSnap.value is Map)
              ? (currentSnap.value as Map)[key]
              : null;
          if (currentVal == null) {
            updates['users/${user.uid}/$key'] = legacyVal[key];
          }
        }
      }

      updates['user/${user.uid}'] = null;

      if (updates.isNotEmpty) {
        await db.ref().update(updates);
      }
    } catch (e) {
      debugPrint('Legacy user migration skipped: $e');
    }
  }

  Future<void> _onLoginPressed() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _status = 'Signing in...';
    });

    try {
      final email = _userCtrl.text.trim();
      final password = _passCtrl.text;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() {
          _busy = false;
          _status = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verify your email to continue.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      if (user != null) {
        await _migrateLegacyUserPath(user);
      }
      // Keep credentials fresh for future biometric re-enable from Settings.
      await BiometricQuickLoginStorage.saveCredentialsOnly(
        email: email,
        password: password,
      );
      await _maybeOfferBiometricEnrollment(email: email, password: password);
      await _loadDataAndNavigate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = '';
      });
      final message = switch (e) {
        FirebaseAuthException(:final code) when code == 'user-not-found' =>
          'User not found',
        FirebaseAuthException(:final code) when code == 'wrong-password' =>
          'Incorrect credentials',
        FirebaseAuthException(:final code) when code == 'invalid-email' =>
          'Invalid email',
        FirebaseAuthException(:final code) when code == 'invalid-credential' =>
          'Incorrect credentials',
        _ => 'Login failed',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _onBiometricPressed({bool isAutoPrompt = false}) async {
    if (_busy) return;

    try {
      if (!await _canUseBiometrics()) {
        if (!mounted) return;
        if (!isAutoPrompt) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available.')),
          );
        }
        return;
      }

      setState(() {
        _busy = true;
        _status = 'Authenticating...';
      });

      final reason = await _biometricPromptReason();
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;
      if (!ok) {
        setState(() {
          _busy = false;
          _status = '';
        });
        return;
      }

      var user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => _status = 'Signing in...');
        final saved = await _readBiometricCredentials();
        if (saved == null) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _status = '';
          });
          if (!isAutoPrompt) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No biometric login found. Log in with email/password once to enable it.',
                ),
              ),
            );
          }
          return;
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: saved['email']!,
          password: saved['password']!,
        );
        user = FirebaseAuth.instance.currentUser;
      }

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No authenticated user after biometric auth.',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() {
          _busy = false;
          _status = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verify your email to continue.'),
          ),
        );
        return;
      }

      await _migrateLegacyUserPath(user);

      await _loadDataAndNavigate();
    } on FirebaseAuthException catch (e) {
      await _clearBiometricCredentials();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = '';
      });
      final message = switch (e.code) {
        'wrong-password' || 'user-not-found' || 'invalid-credential' =>
          'Saved biometric login expired. Log in with email/password to re-enable it.',
        _ => 'Biometric sign-in failed.',
      };
      if (!isAutoPrompt) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = '';
      });
      if (!isAutoPrompt) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric auth failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              Image.asset(
                'assets/icons/ic_launcher.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.local_drink, size: 80),
              ),
              const SizedBox(height: 25),

              Card(
                elevation: 8,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 67, 67, 67),
                    width: 0.5,
                  ),
                ),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _busy ? 'Loading...' : 'Login',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        if (_busy) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 14),
                          Text(
                            _status,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ] else ...[
                          TextField(
                            controller: _userCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(CupertinoIcons.person),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLoginPressed(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: 240,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _onLoginPressed,
                                child: const Text('Log In'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateAccountScreen(),
                                ),
                              );
                            },
                            child: const Text('Create account'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Semantics(
                button: true,
                label: 'Use Biometrics',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _onBiometricPressed,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.smiley,
                            color: theme.colorScheme.tertiary,
                            size: 38,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 36,
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.55,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.fingerprint,
                            color: theme.colorScheme.tertiary,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.copyright_outlined,
                    color: theme.hintColor.withValues(alpha: 0.3),
                  ),
                  Text(
                    '  2026, all rights reserved.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

