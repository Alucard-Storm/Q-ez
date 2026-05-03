import '../../entities/quiz.dart';
import '../../entities/user.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/auth_repository.dart';

/// Use case for managing quizzes with admin override permissions
class ManageQuizzesUseCase {
  final QuizRepository _quizRepository;
  final AuthRepository _authRepository;

  ManageQuizzesUseCase(this._quizRepository, this._authRepository);

  /// Get all quizzes in the system
  /// Validates that the current user is an admin
  /// Returns a list of all quizzes
  /// Throws [Exception] if user is not an admin
  Future<List<Quiz>> getAllQuizzes() async {
    await _validateAdminAccess();
    return await _quizRepository.getAllQuizzes();
  }

  /// Get a specific quiz by ID
  /// Validates that the current user is an admin
  /// Returns the quiz if found
  /// Throws [Exception] if user is not an admin
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<Quiz> getQuiz(String quizId) async {
    await _validateAdminAccess();
    return await _quizRepository.getQuizById(quizId);
  }

  /// Update a quiz (admin override)
  /// Validates that the current user is an admin
  /// Admins can update any quiz regardless of who created it
  /// Validates quiz data integrity before update
  /// Throws [Exception] if user is not an admin or data is invalid
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<void> updateQuiz(Quiz quiz) async {
    await _validateAdminAccess();

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

    // Get existing quiz to check if PIN changed
    final existingQuiz = await _quizRepository.getQuizById(quiz.id);

    // If PIN changed, validate uniqueness
    if (quiz.pin != existingQuiz.pin) {
      final isUnique = await _quizRepository.isPinUnique(quiz.pin);
      if (!isUnique) {
        throw Exception('PIN ${quiz.pin} is already in use');
      }
    }

    await _quizRepository.updateQuiz(quiz);
  }

  /// Delete a quiz (admin override)
  /// Validates that the current user is an admin
  /// Admins can delete any quiz regardless of who created it
  /// Automatically deletes all associated quiz attempts (cascade deletion)
  /// Throws [Exception] if user is not an admin
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<void> deleteQuiz(String quizId) async {
    await _validateAdminAccess();
    await _quizRepository.deleteQuiz(quizId);
  }

  /// Activate or deactivate a quiz
  /// Validates that the current user is an admin
  /// Active quizzes can be accessed by students
  /// Inactive quizzes cannot be accessed but are not deleted
  /// Throws [Exception] if user is not an admin
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<void> setQuizActive(String quizId, bool isActive) async {
    await _validateAdminAccess();

    final quiz = await _quizRepository.getQuizById(quizId);
    final updatedQuiz = quiz.copyWith(isActive: isActive);

    await _quizRepository.updateQuiz(updatedQuiz);
  }

  /// Get quizzes by teacher
  /// Validates that the current user is an admin
  /// Returns all quizzes created by a specific teacher
  /// Throws [Exception] if user is not an admin
  Future<List<Quiz>> getQuizzesByTeacher(String teacherId) async {
    await _validateAdminAccess();
    return await _quizRepository.getQuizzesByTeacher(teacherId);
  }

  /// Validate that the current user is an admin
  /// Returns the current user if they are an admin
  /// Throws [Exception] if user is not authenticated or not an admin
  Future<AppUser> _validateAdminAccess() async {
    final currentUser = await _authRepository.getCurrentUser();

    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    if (currentUser.role != UserRole.admin) {
      throw Exception('Only admins can perform this operation');
    }

    return currentUser;
  }
}
