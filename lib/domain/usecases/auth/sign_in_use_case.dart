import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in a user with role validation
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// Sign in a user with email, password, and role
  /// Validates that the authenticated user has the expected role
  /// Returns the authenticated user
  /// Throws [AuthException] if authentication fails or role doesn't match
  Future<User> call({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Authenticate the user with the specified role
    final user = await _authRepository.signIn(email, password, role);

    // Validate that the user's role matches the expected role
    if (user.role != role) {
      throw Exception(
        'Role mismatch: Expected ${role.name}, but user has ${user.role.name}',
      );
    }

    return user;
  }
}
