import '../../entities/user.dart';
import '../../entities/quiz_attempt.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/quiz_attempt_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/quiz_repository.dart';

/// Data class for audit log entry with security violation information
class AuditLogEntry {
  final String attemptId;
  final String studentId;
  final String studentName;
  final String quizId;
  final String quizTitle;
  final List<SecurityViolation> violations;
  final int totalViolations;
  final bool isFlagged;
  final DateTime attemptDate;

  AuditLogEntry({
    required this.attemptId,
    required this.studentId,
    required this.studentName,
    required this.quizId,
    required this.quizTitle,
    required this.violations,
    required this.totalViolations,
    required this.isFlagged,
    required this.attemptDate,
  });
}

/// Use case for viewing audit logs for security monitoring (admin only)
class ViewAuditLogsUseCase {
  final AuthRepository _authRepository;
  final QuizAttemptRepository _quizAttemptRepository;
  final UserRepository _userRepository;
  final QuizRepository _quizRepository;

  ViewAuditLogsUseCase(
    this._authRepository,
    this._quizAttemptRepository,
    this._userRepository,
    this._quizRepository,
  );

  /// Get all security violations and flagged attempts
  /// Validates that the current user is an admin
  /// Returns a list of audit log entries with security violation details
  /// Entries are sorted by date (most recent first)
  /// Throws [Exception] if user is not an admin
  Future<List<AuditLogEntry>> getAllSecurityViolations() async {
    await _validateAdminAccess();

    // Get all students to access their attempts
    final students = await _userRepository.getAllStudents();

    final auditLogs = <AuditLogEntry>[];

    // Collect attempts with violations from all students
    for (final student in students) {
      final attempts = await _quizAttemptRepository.getStudentAttempts(student.id);

      // Filter attempts with violations
      final attemptsWithViolations = attempts.where(
        (a) => a.securityViolations > 0 || a.isFlagged,
      );

      for (final attempt in attemptsWithViolations) {
        try {
          final quiz = await _quizRepository.getQuizById(attempt.quizId);

          auditLogs.add(AuditLogEntry(
            attemptId: attempt.id,
            studentId: student.id,
            studentName: student.name,
            quizId: attempt.quizId,
            quizTitle: quiz.title,
            violations: attempt.violations,
            totalViolations: attempt.securityViolations,
            isFlagged: attempt.isFlagged,
            attemptDate: attempt.startedAt,
          ));
        } catch (e) {
          // Skip if quiz not found (might have been deleted)
          continue;
        }
      }
    }

    // Sort by date (most recent first)
    auditLogs.sort((a, b) => b.attemptDate.compareTo(a.attemptDate));

    return auditLogs;
  }

  /// Get security violations for a specific student
  /// Validates that the current user is an admin
  /// Returns a list of audit log entries for the specified student
  /// Throws [Exception] if user is not an admin
  /// Throws [UserNotFoundException] if student doesn't exist
  Future<List<AuditLogEntry>> getStudentViolations(String studentId) async {
    await _validateAdminAccess();

    final student = await _userRepository.getStudent(studentId);
    final attempts = await _quizAttemptRepository.getStudentAttempts(studentId);

    // Filter attempts with violations
    final attemptsWithViolations = attempts.where(
      (a) => a.securityViolations > 0 || a.isFlagged,
    );

    final auditLogs = <AuditLogEntry>[];

    for (final attempt in attemptsWithViolations) {
      try {
        final quiz = await _quizRepository.getQuizById(attempt.quizId);

        auditLogs.add(AuditLogEntry(
          attemptId: attempt.id,
          studentId: student.id,
          studentName: student.name,
          quizId: attempt.quizId,
          quizTitle: quiz.title,
          violations: attempt.violations,
          totalViolations: attempt.securityViolations,
          isFlagged: attempt.isFlagged,
          attemptDate: attempt.startedAt,
        ));
      } catch (e) {
        // Skip if quiz not found
        continue;
      }
    }

    // Sort by date (most recent first)
    auditLogs.sort((a, b) => b.attemptDate.compareTo(a.attemptDate));

    return auditLogs;
  }

  /// Get security violations for a specific quiz
  /// Validates that the current user is an admin
  /// Returns a list of audit log entries for the specified quiz
  /// Throws [Exception] if user is not an admin
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<List<AuditLogEntry>> getQuizViolations(String quizId) async {
    await _validateAdminAccess();

    final quiz = await _quizRepository.getQuizById(quizId);
    final attempts = await _quizAttemptRepository.getQuizAttempts(quizId);

    // Filter attempts with violations
    final attemptsWithViolations = attempts.where(
      (a) => a.securityViolations > 0 || a.isFlagged,
    );

    final auditLogs = <AuditLogEntry>[];

    for (final attempt in attemptsWithViolations) {
      try {
        final student = await _userRepository.getStudent(attempt.studentId);

        auditLogs.add(AuditLogEntry(
          attemptId: attempt.id,
          studentId: student.id,
          studentName: student.name,
          quizId: quiz.id,
          quizTitle: quiz.title,
          violations: attempt.violations,
          totalViolations: attempt.securityViolations,
          isFlagged: attempt.isFlagged,
          attemptDate: attempt.startedAt,
        ));
      } catch (e) {
        // Skip if student not found
        continue;
      }
    }

    // Sort by date (most recent first)
    auditLogs.sort((a, b) => b.attemptDate.compareTo(a.attemptDate));

    return auditLogs;
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
      throw Exception('Only admins can view audit logs');
    }

    return currentUser;
  }
}
