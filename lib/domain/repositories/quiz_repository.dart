import '../entities/quiz.dart';

/// Repository interface for quiz CRUD operations
abstract class QuizRepository {
  /// Create a new quiz
  /// If quiz.pin is empty, a unique PIN will be auto-generated
  /// Returns the created quiz with generated PIN if applicable
  /// Throws [QuizException] if creation fails or PIN is not unique
  Future<Quiz> createQuiz(Quiz quiz);

  /// Get a quiz by its unique PIN
  /// Returns the quiz if found
  /// Throws [QuizNotFoundException] if no quiz exists with the given PIN
  Future<Quiz> getQuizByPin(String pin);

  /// Get a quiz by its ID
  /// Returns the quiz if found
  /// Throws [QuizNotFoundException] if no quiz exists with the given ID
  Future<Quiz> getQuizById(String id);

  /// Get all quizzes created by a specific teacher
  /// Returns a list of quizzes, empty if none found
  Future<List<Quiz>> getQuizzesByTeacher(String teacherId);

  /// Get all quizzes in the system (admin only)
  /// Returns a list of all quizzes
  Future<List<Quiz>> getAllQuizzes();

  /// Update an existing quiz
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  /// Throws [QuizException] if update fails or PIN is not unique
  Future<void> updateQuiz(Quiz quiz);

  /// Delete a quiz by ID
  /// Also deletes all associated quiz attempts
  /// Throws [QuizNotFoundException] if quiz doesn't exist
  Future<void> deleteQuiz(String id);

  /// Watch quizzes for real-time updates
  /// Returns a stream of quiz lists
  Stream<List<Quiz>> watchQuizzes();

  /// Validate if a PIN is unique
  /// Returns true if the PIN is available, false otherwise
  Future<bool> isPinUnique(String pin);

  /// Generate a unique 6-digit numeric PIN
  /// Returns a unique PIN string
  Future<String> generateUniquePin();
}
