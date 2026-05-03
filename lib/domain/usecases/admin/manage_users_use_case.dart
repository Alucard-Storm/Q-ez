import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/auth_repository.dart';

/// Use case for managing users with CRUD operations (admin only)
class ManageUsersUseCase {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  ManageUsersUseCase(this._userRepository, this._authRepository);

  /// Get all users in the system
  /// Validates that the current user is an admin
  /// Returns a list of all users
  /// Throws [Exception] if user is not an admin
  Future<List<AppUser>> getAllUsers() async {
    await _validateAdminAccess();
    return await _userRepository.getAllUsers();
  }

  /// Get all students in the system
  /// Validates that the current user is an admin
  /// Returns a list of all students
  /// Throws [Exception] if user is not an admin
  Future<List<Student>> getAllStudents() async {
    await _validateAdminAccess();
    return await _userRepository.getAllStudents();
  }

  /// Get all teachers in the system
  /// Validates that the current user is an admin
  /// Returns a list of all teachers
  /// Throws [Exception] if user is not an admin
  Future<List<Teacher>> getAllTeachers() async {
    await _validateAdminAccess();
    return await _userRepository.getAllTeachers();
  }

  /// Get a specific user by ID
  /// Validates that the current user is an admin
  /// Returns the user if found
  /// Throws [Exception] if user is not an admin
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<AppUser> getUser(String userId) async {
    await _validateAdminAccess();
    return await _userRepository.getUser(userId);
  }

  /// Update a user's profile information
  /// Validates that the current user is an admin
  /// Updates user data in the database
  /// Throws [Exception] if user is not an admin
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<void> updateUser(AppUser user) async {
    await _validateAdminAccess();
    await _userRepository.updateUser(user);
  }

  /// Delete a user by ID
  /// Validates that the current user is an admin
  /// Deletes the user and all associated data (cascade deletion)
  /// For students: deletes quiz attempts and leaderboard entries
  /// For teachers: deletes created quizzes and associated attempts
  /// Throws [Exception] if user is not an admin or trying to delete themselves
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<void> deleteUser(String userId) async {
    final currentUser = await _validateAdminAccess();

    // Prevent admin from deleting themselves
    if (currentUser.id == userId) {
      throw Exception('Cannot delete your own account');
    }

    await _userRepository.deleteUser(userId);
  }

  /// Reset a user's password
  /// Validates that the current user is an admin
  /// Sends a password reset email to the user
  /// Throws [Exception] if user is not an admin
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<void> resetUserPassword(String userId) async {
    await _validateAdminAccess();

    // Get the user to get their email
    final user = await _userRepository.getUser(userId);

    // Send password reset email
    await _authRepository.resetPassword(user.email);
  }

  /// Validate that the current user is an admin
  /// Returns the current user if they are an admin
  /// Throws [Exception] if user is not authenticated or not an admin
  Future<AppUser> _validateAdminAccess() async {
    final currentUser = await _authRepository.getCurrentUser();

    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    if (currentUser.role != UserRole.admin) {
      throw Exception('Only admins can perform this operation');
    }

    return currentUser;
  }
}
