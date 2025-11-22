import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

/// Use case for signing up a new user with initial profile setup
class SignUpUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignUpUseCase(this._authRepository, this._userRepository);

  /// Sign up a new user and create their initial profile
  /// For students, initializes level to 1 and empty badge list
  /// For teachers, initializes empty quiz list
  /// For admins, initializes empty audit log list
  /// Returns the newly created user
  /// Throws [AuthException] if registration fails
  Future<User> call({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Create the authentication account
    final user = await _authRepository.signUp(email, password, name, role);

    // Create the initial user profile in the database
    await _userRepository.createUserProfile(user);

    return user;
  }
}
