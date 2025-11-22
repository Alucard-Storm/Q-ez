import '../../entities/quiz.dart';
import '../../repositories/quiz_repository.dart';

/// Use case for creating a new quiz with PIN generation logic
class CreateQuizUseCase {
  final QuizRepository _quizRepository;

  CreateQuizUseCase(this._quizRepository);

  /// Create a new quiz
  /// If the quiz PIN is empty or blank, automatically generates a unique 6-digit PIN
  /// Validates quiz data integrity before creation
  /// Returns the created quiz with generated PIN if applicable
  /// Throws [QuizException] if creation fails or data is invalid
  Future<Quiz> call(Quiz quiz) async {
    // Validate quiz data
    if (quiz.title.trim().isEmpty) {
      throw Exception('Quiz title cannot be empty');
    }

    if (quiz.questions.isEmpty) {
      throw Exception('Quiz must have at least one question');
    }

    // Validate all questions
    for (final question in quiz.questions) {
      if (!question.isValid) {
        throw Exception('Invalid question: ${question.text}');
      }
    }

    // Generate PIN if not provided or empty
    Quiz quizToCreate = quiz;
    if (quiz.pin.trim().isEmpty) {
      final generatedPin = await _quizRepository.generateUniquePin();
      quizToCreate = quiz.copyWith(pin: generatedPin);
    } else {
      // Validate PIN uniqueness if provided
      final isUnique = await _quizRepository.isPinUnique(quiz.pin);
      if (!isUnique) {
        throw Exception('PIN ${quiz.pin} is already in use');
      }
    }

    // Create the quiz
    return await _quizRepository.createQuiz(quizToCreate);
  }
}
