import '../../repositories/quiz_attempt_repository.dart';

/// Use case for submitting an answer with answer recording
class SubmitAnswerUseCase {
  final QuizAttemptRepository _quizAttemptRepository;

  SubmitAnswerUseCase(this._quizAttemptRepository);

  /// Submit an answer for a specific question in a quiz attempt
  /// Validates that the attempt exists and is not completed
  /// Validates that the selected option is valid (0-3)
  /// Records the answer in the attempt
  /// Throws [QuizAttemptException] if attempt doesn't exist or is completed
  /// Throws [Exception] if selected option is invalid
  Future<void> call({
    required String attemptId,
    required String questionId,
    required int selectedOption,
  }) async {
    // Validate selected option (must be 0-3 for MCQ with 4 options)
    if (selectedOption < 0 || selectedOption > 3) {
      throw Exception('Selected option must be between 0 and 3');
    }

    // Get the attempt to validate it exists and is not completed
    final attempt = await _quizAttemptRepository.getAttempt(attemptId);

    if (attempt.isCompleted) {
      throw Exception('Cannot submit answer for a completed quiz attempt');
    }

    // Submit the answer
    await _quizAttemptRepository.submitAnswer(
      attemptId,
      questionId,
      selectedOption,
    );
  }
}
