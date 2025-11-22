import '../entities/quiz_attempt.dart';

/// Repository interface for quiz attempt lifecycle operations
abstract class QuizAttemptRepository {
  /// Start a new quiz attempt for a student
  /// Creates and returns a new QuizAttempt with initial state
  /// Throws [QuizAttemptException] if creation fails
  Future<QuizAttempt> startAttempt(String studentId, String quizId);

  /// Submit an answer for a specific question in an attempt
  /// Records the selected option for the given question
  /// Throws [QuizAttemptException] if attempt doesn't exist or is already completed
  Future<void> submitAnswer(
    String attemptId,
    String questionId,
    int selectedOption,
  );

  /// Complete a quiz attempt
  /// Calculates final score and marks the attempt as completed
  /// Returns the completed QuizAttempt with final score
  /// Throws [QuizAttemptException] if attempt doesn't exist or is already completed
  Future<QuizAttempt> completeAttempt(String attemptId);

  /// Record a security violation for an attempt
  /// Increments violation counter and adds violation to the list
  /// Auto-submits the quiz if violations reach threshold (3)
  /// Throws [QuizAttemptException] if attempt doesn't exist
  Future<void> recordViolation(
    String attemptId,
    SecurityViolationType type,
  );

  /// Get a specific quiz attempt by ID
  /// Returns the QuizAttempt if found
  /// Throws [QuizAttemptNotFoundException] if attempt doesn't exist
  Future<QuizAttempt> getAttempt(String attemptId);

  /// Get all quiz attempts for a specific student
  /// Returns a list of attempts, ordered by startedAt descending
  Future<List<QuizAttempt>> getStudentAttempts(String studentId);

  /// Get all attempts for a specific quiz
  /// Returns a list of attempts, ordered by score descending
  Future<List<QuizAttempt>> getQuizAttempts(String quizId);

  /// Watch a specific quiz attempt for real-time updates
  /// Returns a stream that emits the attempt whenever it changes
  Stream<QuizAttempt> watchAttempt(String attemptId);

  /// Get the current active attempt for a student (if any)
  /// Returns the active attempt or null if no active attempt exists
  Future<QuizAttempt?> getActiveAttempt(String studentId);

  /// Flag a quiz attempt as suspicious
  /// Marks the attempt as flagged due to security violations
  /// Throws [QuizAttemptException] if attempt doesn't exist
  Future<void> flagAttempt(String attemptId);
}
