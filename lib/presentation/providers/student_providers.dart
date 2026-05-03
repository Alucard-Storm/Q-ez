import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_badge_repository.dart';
import '../../data/repositories/firebase_quiz_attempt_repository.dart';
import '../../data/repositories/firebase_quiz_repository.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/badge_repository.dart';
import '../../domain/repositories/quiz_attempt_repository.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/progress/get_leaderboard_use_case.dart';
import '../../domain/usecases/progress/get_progress_dashboard_use_case.dart';
import '../../domain/usecases/progress/get_quiz_top_students_use_case.dart';
import 'auth_providers.dart';

/// Provider for BadgeRepository dependency injection
/// Provides access to badge operations throughout the app
final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return FirebaseBadgeRepository(
    firestore: FirebaseFirestore.instance,
    userRepository: ref.watch(userRepositoryProvider),
  );
});

/// Provider for GetProgressDashboardUseCase
/// Used to fetch comprehensive student progress statistics
final getProgressDashboardUseCaseProvider =
    Provider<GetProgressDashboardUseCase>((ref) {
  return GetProgressDashboardUseCase(
    ref.watch(userRepositoryProvider),
    ref.watch(_quizAttemptRepositoryProvider),
    ref.watch(badgeRepositoryProvider),
  );
});

/// Provider for GetLeaderboardUseCase
/// Used to fetch global leaderboard rankings
final getLeaderboardUseCaseProvider = Provider<GetLeaderboardUseCase>((ref) {
  return GetLeaderboardUseCase(
    ref.watch(userRepositoryProvider),
  );
});

/// Provider for GetQuizTopStudentsUseCase
/// Used to fetch top 10 students for a specific quiz
final getQuizTopStudentsUseCaseProvider =
    Provider<GetQuizTopStudentsUseCase>((ref) {
  return GetQuizTopStudentsUseCase(
    ref.watch(userRepositoryProvider),
    ref.watch(_quizAttemptRepositoryProvider),
  );
});

/// Private provider for QuizAttemptRepository (used by use cases)
final _quizAttemptRepositoryProvider = Provider<QuizAttemptRepository>((ref) {
  return FirebaseQuizAttemptRepository(
    firestore: FirebaseFirestore.instance,
    quizRepository: ref.watch(_quizRepositoryProvider),
  );
});

/// Private provider for QuizRepository (used by use cases)
final _quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return FirebaseQuizRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for student progress dashboard
/// Fetches comprehensive statistics including:
/// - Total quizzes completed
/// - Average score
/// - Current level
/// - Pass/fail counts
/// - Improvement trend
/// - Recent quiz attempts
/// - Earned badges
/// Usage: ref.watch(progressDashboardProvider(studentId))
final progressDashboardProvider =
    FutureProvider.family<ProgressDashboardData, String>((ref, studentId) async {
  final useCase = ref.watch(getProgressDashboardUseCaseProvider);
  return useCase(studentId);
});

/// Provider for global leaderboard
/// Returns students ranked by level and total score
/// Usage: ref.watch(leaderboardProvider(limit))
final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, int>((ref, limit) async {
  final useCase = ref.watch(getLeaderboardUseCaseProvider);
  return useCase(limit: limit);
});

/// Provider for all available badges in the system
/// Returns the complete list of achievement badges
final badgesProvider = FutureProvider<List<Badge>>((ref) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getAllBadges();
});

/// Provider for student's earned badges
/// Returns badges that a specific student has earned
/// Usage: ref.watch(studentBadgesProvider(studentId))
final studentBadgesProvider =
    FutureProvider.family<List<Badge>, String>((ref, studentId) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getStudentBadges(studentId);
});

/// Provider for available badges (not yet earned)
/// Returns badges that a student can still earn
/// Usage: ref.watch(availableBadgesProvider(studentId))
final availableBadgesProvider =
    FutureProvider.family<List<Badge>, String>((ref, studentId) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getAvailableBadges(studentId);
});

/// Provider for top 10 students for a specific quiz
/// Returns students ranked by score and completion time
/// Usage: ref.watch(quizTopStudentsProvider(quizId))
final quizTopStudentsProvider =
    FutureProvider.family<List<QuizTopStudentEntry>, String>((ref, quizId) async {
  final useCase = ref.watch(getQuizTopStudentsUseCaseProvider);
  return useCase(quizId: quizId, limit: 10);
});

/// Provider for student's quiz attempts
/// Returns all quiz attempts for a specific student
/// Usage: ref.watch(studentAttemptsProvider(studentId))
final studentAttemptsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, studentId) async {
  final repository = ref.watch(_quizAttemptRepositoryProvider);
  return repository.getStudentAttempts(studentId);
});

/// Provider for all students in the system
/// Returns a list of all students, used by teachers and admins
/// Usage: ref.watch(allStudentsProvider)
final allStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllStudents();
});
