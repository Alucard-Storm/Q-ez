import '../../entities/quiz.dart';
import '../../entities/quiz_attempt.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/quiz_attempt_repository.dart';

/// Use case for joining a quiz with PIN validation
class JoinQuizUseCase {
  final QuizRepository _quizRepository;
  final QuizAttemptRepository _quizAttemptRepository;

  JoinQuizUseCase(this._quizRepository, this._quizAttemptRepository);

  /// Join a quiz by PIN and start a new attempt
  /// Validates that the PIN is valid and the quiz is active
  /// Checks if the student already has an active attempt
  /// Creates and returns a new quiz attempt
  /// Throws [QuizNotFoundException] if PIN is invalid
  /// Throws [Exception] if quiz is inactive or student has active attempt
  Future<({Quiz quiz, QuizAttempt attempt})> call({
    required String studentId,
    required String pin,
  }) async {
    // Validate PIN format
    if (pin.trim().isEmpty) {
      throw Exception('PIN cannot be empty');
    }

    // Get the quiz by PIN
    final quiz = await _quizRepository.getQuizByPin(pin);

    // Validate that the quiz is active
    if (!quiz.isActive) {
      throw Exception('This quiz is no longer active');
    }

    // Check if student already has an active attempt
    final activeAttempt = await _quizAttemptRepository.getActiveAttempt(studentId);
    if (activeAttempt != null) {
      throw Exception('You already have an active quiz attempt. Please complete it first.');
    }

    // Start a new quiz attempt
    final attempt = await _quizAttemptRepository.startAttempt(studentId, quiz.id);

    return (quiz: quiz, attempt: attempt);
  }
}
