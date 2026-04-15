import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service for biometric authentication using the local_auth package.
///
/// Wraps fingerprint and face ID authentication with platform availability
/// checks. Credentials for re-authentication are stored securely via
/// flutter_secure_storage.
///
/// Requirements: 17.6
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';

  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Returns true if the current platform supports biometric authentication.
  ///
  /// Web is never supported. On mobile, checks device hardware capability.
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Returns true if the device has biometric hardware and enrolled biometrics.
  Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of available biometric types on this device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!isPlatformSupported) return [];
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Prompts the user to authenticate with biometrics.
  ///
  /// Returns true on success, false if authentication fails or is cancelled.
  Future<bool> authenticate({
    String reason = 'Please authenticate to sign in',
  }) async {
    if (!isPlatformSupported) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/pattern fallback
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Stores credentials securely for future biometric re-authentication.
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  /// Retrieves stored credentials, or null if none are saved.
  Future<BiometricCredentials?> getCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    if (email == null || password == null) return null;
    return BiometricCredentials(email: email, password: password);
  }

  /// Returns true if credentials have been stored for biometric login.
  Future<bool> hasStoredCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    return email != null;
  }

  /// Removes stored biometric credentials (e.g. on sign-out or disable).
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
  }
}

/// Holds the email/password pair retrieved from secure storage.
class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({required this.email, required this.password});
}
