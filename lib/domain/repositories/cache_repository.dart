import '../entities/user.dart';
import '../entities/quiz.dart';

/// Repository interface for local caching operations
abstract class CacheRepository {
  // User session caching
  Future<void> cacheUser(User user, {String? token});
  Future<User?> getCachedUser();
  Future<String?> getCachedToken();
  Future<void> clearUserCache();

  // Quiz caching
  Future<void> cacheQuiz(Quiz quiz);
  Future<Quiz?> getCachedQuiz(String quizId);
  Future<List<Quiz>> getAllCachedQuizzes();
  Future<void> clearQuizCache();
  Future<void> removeCachedQuiz(String quizId);

  // Security settings
  Future<void> saveBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> saveMaxViolations(int maxViolations);
  Future<int> getMaxViolations();
  Future<void> saveStrictMode(bool enabled);
  Future<bool> isStrictModeEnabled();

  // Cache management
  Future<void> clearAllCache();
  Future<bool> isCacheValid();
  Future<void> invalidateCache();
}
