import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricQuickLoginStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _enabledKey = 'biometric_quick_login_enabled';
  static const String _emailKey = 'biometric_quick_login_email';
  static const String _passwordKey = 'biometric_quick_login_password';

  static Future<bool> isEnabled() async {
    return (await _storage.read(key: _enabledKey)) == 'true';
  }

  static Future<void> setEnabled(bool value) {
    return _storage.write(key: _enabledKey, value: value ? 'true' : 'false');
  }

  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await saveCredentialsOnly(email: email, password: password);
    await setEnabled(true);
  }

  static Future<void> saveCredentialsOnly({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<Map<String, String>?> readCredentials() async {
    final enabled = await isEnabled();
    if (!enabled) return null;

    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      return null;
    }
    return {'email': email, 'password': password};
  }

  static Future<bool> hasCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    return (email?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false);
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _enabledKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
}
