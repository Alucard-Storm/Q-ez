import '../../entities/user.dart';
import '../../entities/quiz_attempt.dart';
import '../../entities/badge.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/quiz_attempt_repository.dart';
import '../../repositories/badge_repository.dart';

/// Data class for progress dashboard statistics
class ProgressDashboardData {
  final Student student;
  final List<QuizAttempt> recentAttempts;
  final List<Badge> earnedBadges;
  final int totalQuizzes;
  final double averageScore;
  final int currentLevel;
  final int passCount;
  final int failCount;
  final double improvementTrend;

  ProgressDashboardData({
    required this.student,
    required this.recentAttempts,
    required this.earnedBadges,
    required this.totalQuizzes,
    required this.averageScore,
    required this.currentLevel,
    required this.passCount,
    required this.failCount,
    required this.improvementTrend,
  });
}

/// Use case for getting progress dashboard with statistics calculation
class GetProgressDashboardUseCase {
  final UserRepository _userRepository;
  final QuizAttemptRepository _quizAttemptRepository;
  final BadgeRepository _badgeRepository;

  GetProgressDashboardUseCase(
    this._userRepository,
    this._quizAttemptRepository,
    this._badgeRepository,
  );

  /// Get comprehensive progress dashboard data for a student
  /// Calculates statistics including:
  /// - Total quizzes completed
  /// - Average score
  /// - Current level
  /// - Pass/fail counts
  /// - Improvement trend (percentage change over last 10 quizzes)
  /// - Recent quiz attempts
  /// - Earned badges
  /// Returns [ProgressDashboardData] with all calculated statistics
  Future<ProgressDashboardData> call(String studentId) async {
    // Get student data
    final student = await _userRepository.getStudent(studentId);

    // Get all quiz attempts for the student
    final allAttempts = await _quizAttemptRepository.getStudentAttempts(studentId);

    // Filter only completed attempts
    final completedAttempts = allAttempts.where((a) => a.isCompleted).toList();

    // Get earned badges
    final earnedBadges = await _badgeRepository.getStudentBadges(studentId);

    // Calculate pass/fail counts (60% is passing threshold)
    final passCount = completedAttempts.where((a) => a.scorePercentage >= 60.0).length;
    final failCount = completedAttempts.length - passCount;

    // Calculate improvement trend over last 10 quizzes
    double improvementTrend = 0.0;
    if (completedAttempts.length >= 2) {
      final last10 = completedAttempts.take(10).toList();
      
      if (last10.length >= 2) {
        // Split into two halves
        final halfPoint = last10.length ~/ 2;
        final firstHalf = last10.sublist(halfPoint);
        final secondHalf = last10.sublist(0, halfPoint);

        // Calculate average scores for each half
        final firstHalfAvg = firstHalf.isEmpty
            ? 0.0
            : firstHalf.map((a) => a.scorePercentage).reduce((a, b) => a + b) / firstHalf.length;
        final secondHalfAvg = secondHalf.isEmpty
            ? 0.0
            : secondHalf.map((a) => a.scorePercentage).reduce((a, b) => a + b) / secondHalf.length;

        // Calculate percentage change
        if (firstHalfAvg > 0) {
          improvementTrend = ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100;
        }
      }
    }

    return ProgressDashboardData(
      student: student,
      recentAttempts: completedAttempts,
      earnedBadges: earnedBadges,
      totalQuizzes: student.totalQuizzesTaken,
      averageScore: student.averageScore,
      currentLevel: student.level,
      passCount: passCount,
      failCount: failCount,
      improvementTrend: improvementTrend,
    );
  }
}
