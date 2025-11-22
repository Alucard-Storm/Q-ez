import 'package:hive/hive.dart';

part 'security_settings.g.dart';

@HiveType(typeId: 3)
class SecuritySettings extends HiveObject {
  @HiveField(0)
  bool biometricEnabled;

  @HiveField(1)
  int maxViolations;

  @HiveField(2)
  bool strictMode;

  SecuritySettings({
    required this.biometricEnabled,
    required this.maxViolations,
    required this.strictMode,
  });

  factory SecuritySettings.defaultSettings() {
    return SecuritySettings(
      biometricEnabled: false,
      maxViolations: 3,
      strictMode: true,
    );
  }
}
