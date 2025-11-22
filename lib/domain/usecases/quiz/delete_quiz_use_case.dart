import '../../entities/user.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/auth_repository.dart';

/// Use case for deleting a quiz with cascade deletion
class DeleteQuizUseCase {
  final QuizRepository _quizRepository;
  final AuthRepository _authRepository;

  DeleteQuizUseCase(this._quizRepository, this._authRepository);

  /// Delete a quiz by ID
  /// Validates that the current user has permission to delete the quiz
  /// Teachers can only delete their own quizzes
  /// Admins can delete any quiz
  /// Automatically deletes all associated quiz attempts (cascade deletion)
  /// Throws [QuizException] if deletion fails or user lacks permission
  Future<void> call(String quizId) async {
    // Get current user
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User must be authenticated to delete a quiz');
    }

    // Get the quiz to check ownership
    final quiz = await _quizRepository.getQuizById(quizId);

    // Validate permissions
    if (currentUser.role == UserRole.teacher) {
      if (quiz.teacherId != currentUser.id) {
        throw Exception('Teachers can only delete their own quizzes');
      }
    } else if (currentUser.role != UserRole.admin) {
      throw Exception('Only teachers and admins can delete quizzes');
    }

    // Delete the quiz (cascade deletion of attempts handled by repository)
    await _quizRepository.deleteQuiz(quizId);
  }
}
