import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password for a specific role
  /// Returns the authenticated user
  /// Throws [AuthException] if authentication fails
  Future<User> signIn(String email, String password, UserRole role);

  /// Sign up a new user with email, password, name, and role
  /// Returns the newly created user
  /// Throws [AuthException] if registration fails
  Future<User> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  );

  /// Sign out the current user
  /// Throws [AuthException] if sign out fails
  Future<void> signOut();

  /// Stream of authentication state changes
  /// Emits the current user when authenticated, null when not authenticated
  Stream<User?> authStateChanges();

  /// Send password reset email
  /// Throws [AuthException] if the operation fails
  Future<void> resetPassword(String email);

  /// Get the current authenticated user
  /// Returns null if no user is authenticated
  Future<User?> getCurrentUser();
}
