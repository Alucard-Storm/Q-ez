import '../../entities/user.dart';
import '../../entities/quiz_attempt.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/quiz_attempt_repository.dart';

/// Data class for quiz top student entry with ranking information
class QuizTopStudentEntry {
  final Student student;
  final QuizAttempt attempt;
  final int rank;
  final double score;
  final Duration? completionTime;

  QuizTopStudentEntry({
    required this.student,
    required this.attempt,
    required this.rank,
    required this.score,
    this.completionTime,
  });
}

/// Use case for getting top 10 students for a specific quiz
class GetQuizTopStudentsUseCase {
  final UserRepository _userRepository;
  final QuizAttemptRepository _quizAttemptRepository;

  GetQuizTopStudentsUseCase(
    this._userRepository,
    this._quizAttemptRepository,
  );

  /// Get the top students for a specific quiz
  /// Students are ranked by:
  /// 1. Score (descending) - higher score ranks higher
  /// 2. Completion time (ascending) - faster completion ranks higher when scores are equal
  /// Returns a list of [QuizTopStudentEntry] with rank, student, score, and completion time
  /// The limit parameter controls how many entries to return (default: 10)
  Future<List<QuizTopStudentEntry>> call({
    required String quizId,
    int limit = 10,
  }) async {
    // Get all attempts for the quiz
    final attempts = await _quizAttemptRepository.getQuizAttempts(quizId);

    // Filter only completed attempts
    final completedAttempts = attempts.where((a) => a.isCompleted).toList();

    // Sort by score (descending) and completion time (ascending)
    completedAttempts.sort((a, b) {
      // First compare by score
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      // If scores are equal, compare by completion time
      if (a.duration != null && b.duration != null) {
        return a.duration!.compareTo(b.duration!);
      }

      // If one has no duration, prioritize the one with duration
      if (a.duration != null) return -1;
      if (b.duration != null) return 1;

      return 0;
    });

    // Take top N attempts
    final topAttempts = completedAttempts.take(limit).toList();

    // Create entries with student data
    final entries = <QuizTopStudentEntry>[];
    
    for (int i = 0; i < topAttempts.length; i++) {
      final attempt = topAttempts[i];
      
      try {
        final student = await _userRepository.getStudent(attempt.studentId);
        
        entries.add(QuizTopStudentEntry(
          student: student,
          attempt: attempt,
          rank: i + 1,
          score: attempt.score,
          completionTime: attempt.duration,
        ));
      } catch (e) {
        // Skip if student not found (might have been deleted)
        continue;
      }
    }

    return entries;
  }
}
