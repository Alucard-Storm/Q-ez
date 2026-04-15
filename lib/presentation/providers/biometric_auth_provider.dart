import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/config/hive_config.dart';
import '../../data/models/security_settings.dart';
import '../../data/services/biometric_auth_service.dart';

/// Provider for the BiometricAuthService singleton.
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

/// State class representing the current biometric availability and preference.
class BiometricState {
  final bool isAvailable;
  final bool isEnabled;
  final bool hasCredentials;

  const BiometricState({
    required this.isAvailable,
    required this.isEnabled,
    required this.hasCredentials,
  });

  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    bool? hasCredentials,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      hasCredentials: hasCredentials ?? this.hasCredentials,
    );
  }
}

/// Notifier that manages biometric authentication state.
///
/// Reads/writes the [SecuritySettings] Hive model for the enabled preference
/// and delegates credential storage to [BiometricAuthService].
class BiometricAuthNotifier extends StateNotifier<AsyncValue<BiometricState>> {
  final BiometricAuthService _service;

  BiometricAuthNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final available = await _service.isAvailable();
      final enabled = _readEnabledSetting();
      final hasCredentials = await _service.hasStoredCredentials();

      state = AsyncValue.data(BiometricState(
        isAvailable: available,
        isEnabled: enabled,
        hasCredentials: hasCredentials,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool _readEnabledSetting() {
    final Box<SecuritySettings> box = HiveConfig.getSecurityBox();
    final settings = box.get('settings');
    return settings?.biometricEnabled ?? false;
  }

  Future<void> _writeEnabledSetting(bool value) async {
    final Box<SecuritySettings> box = HiveConfig.getSecurityBox();
    final existing = box.get('settings');
    if (existing != null) {
      existing.biometricEnabled = value;
      await existing.save();
    } else {
      await box.put(
        'settings',
        SecuritySettings(
          biometricEnabled: value,
          maxViolations: 3,
          strictMode: true,
        ),
      );
    }
  }

  /// Enables biometric auth and stores the provided credentials securely.
  Future<void> enable({
    required String email,
    required String password,
  }) async {
    await _service.saveCredentials(email: email, password: password);
    await _writeEnabledSetting(true);
    state = state.whenData((s) => s.copyWith(isEnabled: true, hasCredentials: true));
  }

  /// Disables biometric auth and removes stored credentials.
  Future<void> disable() async {
    await _service.clearCredentials();
    await _writeEnabledSetting(false);
    state = state.whenData((s) => s.copyWith(isEnabled: false, hasCredentials: false));
  }

  /// Toggles the biometric enabled setting.
  ///
  /// When enabling, [email] and [password] must be provided so credentials
  /// can be stored for future re-authentication.
  Future<void> toggle({String? email, String? password}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (current.isEnabled) {
      await disable();
    } else {
      if (email != null && password != null) {
        await enable(email: email, password: password);
      }
    }
  }

  /// Performs biometric authentication and returns the stored credentials
  /// on success, or null if authentication fails.
  Future<BiometricCredentials?> authenticateAndGetCredentials() async {
    final authenticated = await _service.authenticate(
      reason: 'Sign in with biometrics',
    );
    if (!authenticated) return null;
    return _service.getCredentials();
  }

  /// Refreshes availability state (e.g. after returning from settings).
  Future<void> refresh() => _init();
}

/// Provider for [BiometricAuthNotifier].
final biometricAuthProvider =
    StateNotifierProvider<BiometricAuthNotifier, AsyncValue<BiometricState>>(
  (ref) {
    final service = ref.watch(biometricAuthServiceProvider);
    return BiometricAuthNotifier(service);
  },
);
