import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/cache_repository.dart';
import '../../core/config/hive_config.dart';
import '../models/cached_user.dart';
import '../models/cached_quiz.dart';
import '../models/security_settings.dart';

class HiveCacheRepository implements CacheRepository {
  static const String _currentUserKey = 'current_user';
  static const String _securitySettingsKey = 'security_settings';

  Box<CachedUser> get _userBox => HiveConfig.getUserBox();
  Box<CachedQuiz> get _quizBox => HiveConfig.getQuizBox();
  Box<SecuritySettings> get _securityBox => HiveConfig.getSecurityBox();

  // User session caching

  @override
  Future<void> cacheUser(AppUser user, {String? token}) async {
    final cachedUser = _convertUserToCached(user, token);
    await _userBox.put(_currentUserKey, cachedUser);
  }

  @override
  Future<AppUser?> getCachedUser() async {
    final cachedUser = _userBox.get(_currentUserKey);
    if (cachedUser == null) return null;

    return _convertCachedToUser(cachedUser);
  }

  @override
  Future<String?> getCachedToken() async {
    final cachedUser = _userBox.get(_currentUserKey);
    return cachedUser?.encryptedToken;
  }

  @override
  Future<void> clearUserCache() async {
    await _userBox.delete(_currentUserKey);
  }

  // Quiz caching

  @override
  Future<void> cacheQuiz(Quiz quiz) async {
    final cachedQuiz = _convertQuizToCached(quiz);
    await _quizBox.put(quiz.id, cachedQuiz);
  }

  @override
  Future<Quiz?> getCachedQuiz(String quizId) async {
    final cachedQuiz = _quizBox.get(quizId);
    if (cachedQuiz == null) return null;

    return _convertCachedToQuiz(cachedQuiz);
  }

  @override
  Future<List<Quiz>> getAllCachedQuizzes() async {
    final cachedQuizzes = _quizBox.values.toList();
    return cachedQuizzes.map(_convertCachedToQuiz).toList();
  }

  @override
  Future<void> clearQuizCache() async {
    await _quizBox.clear();
  }

  @override
  Future<void> removeCachedQuiz(String quizId) async {
    await _quizBox.delete(quizId);
  }

  // Security settings

  @override
  Future<void> saveBiometricEnabled(bool enabled) async {
    final settings = await _getOrCreateSecuritySettings();
    settings.biometricEnabled = enabled;
    await _securityBox.put(_securitySettingsKey, settings);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final settings = await _getOrCreateSecuritySettings();
    return settings.biometricEnabled;
  }

  @override
  Future<void> saveMaxViolations(int maxViolations) async {
    final settings = await _getOrCreateSecuritySettings();
    settings.maxViolations = maxViolations;
    await _securityBox.put(_securitySettingsKey, settings);
  }

  @override
  Future<int> getMaxViolations() async {
    final settings = await _getOrCreateSecuritySettings();
    return settings.maxViolations;
  }

  @override
  Future<void> saveStrictMode(bool enabled) async {
    final settings = await _getOrCreateSecuritySettings();
    settings.strictMode = enabled;
    await _securityBox.put(_securitySettingsKey, settings);
  }

  @override
  Future<bool> isStrictModeEnabled() async {
    final settings = await _getOrCreateSecuritySettings();
    return settings.strictMode;
  }

  // Cache management

  @override
  Future<void> clearAllCache() async {
    await HiveConfig.clearAll();
  }

  @override
  Future<bool> isCacheValid() async {
    // Use a separate key-value approach for cache validity
    final cachedUser = _userBox.get(_currentUserKey);
    return cachedUser != null;
  }

  @override
  Future<void> invalidateCache() async {
    await clearAllCache();
  }

  // Helper methods

  Future<SecuritySettings> _getOrCreateSecuritySettings() async {
    var settings = _securityBox.get(_securitySettingsKey);
    if (settings == null) {
      settings = SecuritySettings.defaultSettings();
      await _securityBox.put(_securitySettingsKey, settings);
    }
    return settings;
  }

  CachedUser _convertUserToCached(AppUser user, String? token) {
    if (user is Student) {
      return CachedUser(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role.name,
        level: user.level,
        badgeIds: user.badgeIds,
        totalQuizzesTaken: user.totalQuizzesTaken,
        averageScore: user.averageScore,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        encryptedToken: token,
      );
    } else if (user is Teacher) {
      return CachedUser(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role.name,
        createdQuizIds: user.createdQuizIds,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        encryptedToken: token,
      );
    } else if (user is Admin) {
      return CachedUser(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role.name,
        auditLogIds: user.auditLogIds,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        encryptedToken: token,
      );
    } else {
      // Fallback for base User type
      return CachedUser(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role.name,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        encryptedToken: token,
      );
    }
  }

  AppUser _convertCachedToUser(CachedUser cached) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == cached.role,
      orElse: () => UserRole.student,
    );

    switch (role) {
      case UserRole.student:
        return Student(
          id: cached.id,
          email: cached.email,
          name: cached.name,
          role: role,
          createdAt: cached.createdAt,
          lastLoginAt: cached.lastLoginAt,
          level: cached.level ?? 1,
          badgeIds: cached.badgeIds ?? [],
          totalQuizzesTaken: cached.totalQuizzesTaken ?? 0,
          averageScore: cached.averageScore ?? 0.0,
        );
      case UserRole.teacher:
        return Teacher(
          id: cached.id,
          email: cached.email,
          name: cached.name,
          role: role,
          createdAt: cached.createdAt,
          lastLoginAt: cached.lastLoginAt,
          createdQuizIds: cached.createdQuizIds ?? [],
        );
      case UserRole.admin:
        return Admin(
          id: cached.id,
          email: cached.email,
          name: cached.name,
          role: role,
          createdAt: cached.createdAt,
          lastLoginAt: cached.lastLoginAt,
          auditLogIds: cached.auditLogIds ?? [],
        );
    }
  }

  CachedQuiz _convertQuizToCached(Quiz quiz) {
    return CachedQuiz(
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      teacherId: quiz.teacherId,
      pin: quiz.pin,
      timeLimitMinutes: quiz.timeLimitMinutes,
      questions: quiz.questions
          .map((q) => CachedQuestion(
                id: q.id,
                text: q.text,
                options: q.options,
                correctOptionIndex: q.correctOptionIndex,
              ))
          .toList(),
      createdAt: quiz.createdAt,
      isActive: quiz.isActive,
    );
  }

  Quiz _convertCachedToQuiz(CachedQuiz cached) {
    return Quiz(
      id: cached.id,
      title: cached.title,
      description: cached.description,
      teacherId: cached.teacherId,
      pin: cached.pin,
      timeLimitMinutes: cached.timeLimitMinutes,
      questions: cached.questions
          .map((q) => Question(
                id: q.id,
                text: q.text,
                options: q.options,
                correctOptionIndex: q.correctOptionIndex,
              ))
          .toList(),
      createdAt: cached.createdAt,
      isActive: cached.isActive,
    );
  }
}
