import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_quiz_attempt_repository.dart';
import '../../data/repositories/firebase_quiz_repository.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/quiz_attempt_repository.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/admin/manage_quizzes_use_case.dart';
import '../../domain/usecases/admin/manage_users_use_case.dart';
import '../../domain/usecases/admin/view_audit_logs_use_case.dart';
import 'auth_providers.dart';

/// Provider for ManageUsersUseCase
/// Used by admins to perform CRUD operations on users
final manageUsersUseCaseProvider = Provider<ManageUsersUseCase>((ref) {
  return ManageUsersUseCase(
    ref.watch(userRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});

/// Provider for ManageQuizzesUseCase
/// Used by admins to perform CRUD operations on quizzes with override permissions
final manageQuizzesUseCaseProvider = Provider<ManageQuizzesUseCase>((ref) {
  return ManageQuizzesUseCase(
    ref.watch(_adminQuizRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});

/// Provider for ViewAuditLogsUseCase
/// Used by admins to view security violations and audit logs
final viewAuditLogsUseCaseProvider = Provider<ViewAuditLogsUseCase>((ref) {
  return ViewAuditLogsUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(_adminQuizAttemptRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(_adminQuizRepositoryProvider),
  );
});

/// Private provider for QuizRepository (used by admin use cases)
final _adminQuizRepositoryProvider = Provider<QuizRepository>((ref) {
  return FirebaseQuizRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// Private provider for QuizAttemptRepository (used by admin use cases)
final _adminQuizAttemptRepositoryProvider =
    Provider<QuizAttemptRepository>((ref) {
  return FirebaseQuizAttemptRepository(
    firestore: FirebaseFirestore.instance,
    quizRepository: ref.watch(_adminQuizRepositoryProvider),
  );
});

/// Provider for all users in the system (admin only)
/// Returns a list of all users regardless of role
/// Throws exception if current user is not an admin
final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final useCase = ref.watch(manageUsersUseCaseProvider);
  return useCase.getAllUsers();
});

/// Provider for all students in the system (admin only)
/// Returns a list of all students
/// Throws exception if current user is not an admin
final adminAllStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final useCase = ref.watch(manageUsersUseCaseProvider);
  return useCase.getAllStudents();
});

/// Provider for all teachers in the system (admin only)
/// Returns a list of all teachers
/// Throws exception if current user is not an admin
final allTeachersProvider = FutureProvider<List<Teacher>>((ref) async {
  final useCase = ref.watch(manageUsersUseCaseProvider);
  return useCase.getAllTeachers();
});

/// Provider for a specific user by ID (admin only)
/// Usage: ref.watch(userByIdProvider(userId))
final userByIdProvider =
    FutureProvider.family<AppUser, String>((ref, userId) async {
  final useCase = ref.watch(manageUsersUseCaseProvider);
  return useCase.getUser(userId);
});

/// Provider for all quizzes in the system (admin only)
/// Returns a list of all quizzes regardless of creator
/// Throws exception if current user is not an admin
final allQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  final useCase = ref.watch(manageQuizzesUseCaseProvider);
  return useCase.getAllQuizzes();
});

/// Provider for quizzes by teacher (admin only)
/// Returns all quizzes created by a specific teacher
/// Usage: ref.watch(quizzesByTeacherAdminProvider(teacherId))
final quizzesByTeacherAdminProvider =
    FutureProvider.family<List<Quiz>, String>((ref, teacherId) async {
  final useCase = ref.watch(manageQuizzesUseCaseProvider);
  return useCase.getQuizzesByTeacher(teacherId);
});

/// Provider for all security violations and audit logs (admin only)
/// Returns a list of all attempts with security violations
/// Sorted by date (most recent first)
/// Throws exception if current user is not an admin
final auditLogsProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  final useCase = ref.watch(viewAuditLogsUseCaseProvider);
  return useCase.getAllSecurityViolations();
});

/// Provider for security violations by student (admin only)
/// Returns audit logs for a specific student
/// Usage: ref.watch(studentViolationsProvider(studentId))
final studentViolationsProvider =
    FutureProvider.family<List<AuditLogEntry>, String>((ref, studentId) async {
  final useCase = ref.watch(viewAuditLogsUseCaseProvider);
  return useCase.getStudentViolations(studentId);
});

/// Provider for security violations by quiz (admin only)
/// Returns audit logs for a specific quiz
/// Usage: ref.watch(quizViolationsProvider(quizId))
final quizViolationsProvider =
    FutureProvider.family<List<AuditLogEntry>, String>((ref, quizId) async {
  final useCase = ref.watch(viewAuditLogsUseCaseProvider);
  return useCase.getQuizViolations(quizId);
});
