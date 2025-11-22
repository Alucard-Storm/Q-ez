import '../../repositories/auth_repository.dart';
import '../../repositories/cache_repository.dart';

/// Use case for signing out a user with cache clearing
class SignOutUseCase {
  final AuthRepository _authRepository;
  final CacheRepository _cacheRepository;

  SignOutUseCase(this._authRepository, this._cacheRepository);

  /// Sign out the current user and clear all cached data
  /// Clears user session, cached quizzes, and security settings
  /// Throws [AuthException] if sign out fails
  Future<void> call() async {
    // Sign out from authentication service
    await _authRepository.signOut();

    // Clear all cached data
    await _cacheRepository.clearAllCache();
  }
}
