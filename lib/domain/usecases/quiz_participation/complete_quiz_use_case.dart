import '../../repositories/quiz_attempt_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/badge_repository.dart';

/// Use case for completing a quiz with score calculation, level update, and badge awarding
class CompleteQuizUseCase {
  final QuizAttemptRepository _quizAttemptRepository;
  final UserRepository _userRepository;
  final BadgeRepository _badgeRepository;

  CompleteQuizUseCase(
    this._quizAttemptRepository,
    this._userRepository,
    this._badgeRepository,
  );

  /// Complete a quiz attempt
  /// Calculates final score and marks the attempt as completed
  /// Updates student level if score is 60% or higher (passing threshold)
  /// Updates student statistics (total quizzes taken, average score)
  /// Checks and awards any newly earned badges
  /// Returns the completed attempt with final score
  /// Throws [QuizAttemptException] if attempt doesn't exist or is already completed
  Future<({
    double score,
    bool passed,
    int? newLevel,
    List<String> newBadges,
  })> call(String attemptId) async {
    // Complete the attempt and get final score
    final completedAttempt = await _quizAttemptRepository.completeAttempt(attemptId);

    // Get the student
    final student = await _userRepository.getStudent(completedAttempt.studentId);

    // Calculate if student passed (60% or higher)
    final scorePercentage = completedAttempt.scorePercentage;
    final passed = scorePercentage >= 60.0;

    // Update student level if passed
    int? newLevel;
    if (passed) {
      newLevel = student.level + 1;
      await _userRepository.updateStudentLevel(student.id, newLevel);
    }

    // Update student statistics
    final newTotalQuizzes = student.totalQuizzesTaken + 1;
    final newAverageScore = ((student.averageScore * student.totalQuizzesTaken) + 
        completedAttempt.score) / newTotalQuizzes;
    
    await _userRepository.updateStudentStats(
      student.id,
      newTotalQuizzes,
      newAverageScore,
    );

    // Check and award badges
    final newBadges = await _badgeRepository.checkAndAwardBadges(student.id);

    return (
      score: completedAttempt.score,
      passed: passed,
      newLevel: newLevel,
      newBadges: newBadges,
    );
  }
}
