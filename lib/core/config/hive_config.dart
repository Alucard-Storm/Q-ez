import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/cached_user.dart';
import '../../data/models/cached_quiz.dart';
import '../../data/models/security_settings.dart';
import '../../data/models/pending_operation.dart';

class HiveConfig {
  static const String userBoxName = 'user_box';
  static const String quizBoxName = 'quiz_box';
  static const String securityBoxName = 'security_box';
  static const String pendingOperationsBoxName = 'pending_operations_box';
  static const String encryptionKeyName = 'hive_encryption_key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Initialize Hive with Flutter integration
  static Future<void> initialize() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    // Get or generate encryption key
    final encryptionKey = await _getEncryptionKey();

    // Open encrypted boxes for sensitive data
    await Hive.openBox<CachedUser>(
      userBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // Open regular boxes for non-sensitive data
    await Hive.openBox<CachedQuiz>(quizBoxName);
    
    // Open encrypted box for security settings
    await Hive.openBox<SecuritySettings>(
      securityBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // Open box for pending offline operations
    await Hive.openBox<PendingOperation>(pendingOperationsBoxName);
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedUserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedQuestionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CachedQuizAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SecuritySettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PendingOperationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PendingOperationAdapter());
    }
  }

  /// Get or generate encryption key for Hive boxes
  static Future<List<int>> _getEncryptionKey() async {
    // Try to read existing key
    final existingKey = await _secureStorage.read(key: encryptionKeyName);

    if (existingKey != null) {
      return existingKey.codeUnits;
    }

    // Generate new key if not exists
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: encryptionKeyName,
      value: String.fromCharCodes(key),
    );

    return key;
  }

  /// Get user box
  static Box<CachedUser> getUserBox() {
    return Hive.box<CachedUser>(userBoxName);
  }

  /// Get quiz box
  static Box<CachedQuiz> getQuizBox() {
    return Hive.box<CachedQuiz>(quizBoxName);
  }

  /// Get security settings box
  static Box<SecuritySettings> getSecurityBox() {
    return Hive.box<SecuritySettings>(securityBoxName);
  }

  /// Get pending operations box
  static Box<PendingOperation> getPendingOperationsBox() {
    return Hive.box<PendingOperation>(pendingOperationsBoxName);
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    await getUserBox().clear();
    await getQuizBox().clear();
    await getSecurityBox().clear();
  }

  /// Clear user data only
  static Future<void> clearUserData() async {
    await getUserBox().clear();
  }

  /// Clear quiz cache only
  static Future<void> clearQuizCache() async {
    await getQuizBox().clear();
  }
}
