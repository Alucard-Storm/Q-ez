import '../../entities/quiz.dart';
import '../../repositories/quiz_repository.dart';

/// Use case for getting a quiz by PIN for student quiz access
class GetQuizByPinUseCase {
  final QuizRepository _quizRepository;

  GetQuizByPinUseCase(this._quizRepository);

  /// Get a quiz by its unique PIN
  /// Validates that the quiz is active before returning
  /// Returns the quiz if found and active
  /// Throws [QuizNotFoundException] if no quiz exists with the given PIN
  /// Throws [Exception] if the quiz is inactive
  Future<Quiz> call(String pin) async {
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

    return quiz;
  }
}
