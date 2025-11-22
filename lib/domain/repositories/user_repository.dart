import '../entities/user.dart';

/// Repository interface for user management operations
abstract class UserRepository {
  /// Get a student by ID
  /// Returns the Student if found
  /// Throws [UserNotFoundException] if student doesn't exist
  Future<Student> getStudent(String id);

  /// Get a teacher by ID
  /// Returns the Teacher if found
  /// Throws [UserNotFoundException] if teacher doesn't exist
  Future<Teacher> getTeacher(String id);

  /// Get an admin by ID
  /// Returns the Admin if found
  /// Throws [UserNotFoundException] if admin doesn't exist
  Future<Admin> getAdmin(String id);

  /// Get a user by ID (any role)
  /// Returns the User if found
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<User> getUser(String id);

  /// Update a student's level
  /// Throws [UserNotFoundException] if student doesn't exist
  Future<void> updateStudentLevel(String id, int newLevel);

  /// Update student statistics after quiz completion
  /// Updates totalQuizzesTaken and averageScore
  /// Throws [UserNotFoundException] if student doesn't exist
  Future<void> updateStudentStats(
    String id,
    int totalQuizzes,
    double averageScore,
  );

  /// Award a badge to a student
  /// Adds the badge ID to the student's badgeIds list
  /// Throws [UserNotFoundException] if student doesn't exist
  Future<void> awardBadge(String studentId, String badgeId);

  /// Get the global leaderboard
  /// Returns students ranked by level (descending) and total score (descending)
  /// Limited to the specified number of students
  Future<List<Student>> getLeaderboard(int limit);

  /// Get top students for a specific quiz
  /// Returns students ranked by score (descending) and completion time (ascending)
  /// Limited to the specified number of students (typically 10)
  Future<List<Student>> getTopStudentsForQuiz(String quizId, int limit);

  /// Get all users in the system (admin only)
  /// Returns a list of all users regardless of role
  Future<List<User>> getAllUsers();

  /// Get all students in the system
  /// Returns a list of all students
  Future<List<Student>> getAllStudents();

  /// Get all teachers in the system
  /// Returns a list of all teachers
  Future<List<Teacher>> getAllTeachers();

  /// Update a user's profile information
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<void> updateUser(User user);

  /// Delete a user by ID
  /// Also deletes all associated data (quiz attempts for students, quizzes for teachers)
  /// Throws [UserNotFoundException] if user doesn't exist
  Future<void> deleteUser(String id);

  /// Create a new user profile after authentication
  /// Used during sign up to create the initial user document
  Future<void> createUserProfile(User user);
}
