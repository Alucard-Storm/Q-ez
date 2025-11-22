import '../../entities/quiz.dart';
import '../../entities/user.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/auth_repository.dart';

/// Use case for updating a quiz with permission validation
class UpdateQuizUseCase {
  final QuizRepository _quizRepository;
  final AuthRepository _authRepository;

  UpdateQuizUseCase(this._quizRepository, this._authRepository);

  /// Update an existing quiz
  /// Validates that the current user has permission to update the quiz
  /// Teachers can only update their own quizzes
  /// Admins can update any quiz
  /// Validates quiz data integrity before update
  /// Throws [QuizException] if update fails or user lacks permission
  Future<void> call(Quiz quiz) async {
    // Get current user
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User must be authenticated to update a quiz');
    }

    // Get the existing quiz to check ownership
    final existingQuiz = await _quizRepository.getQuizById(quiz.id);

    // Validate permissions
    if (currentUser.role == UserRole.teacher) {
      if (existingQuiz.teacherId != currentUser.id) {
        throw Exception('Teachers can only update their own quizzes');
      }
    } else if (currentUser.role != UserRole.admin) {
      throw Exception('Only teachers and admins can update quizzes');
    }

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

    // If PIN changed, validate uniqueness
    if (quiz.pin != existingQuiz.pin) {
      final isUnique = await _quizRepository.isPinUnique(quiz.pin);
      if (!isUnique) {
        throw Exception('PIN ${quiz.pin} is already in use');
      }
    }

    // Update the quiz
    await _quizRepository.updateQuiz(quiz);
  }
}
