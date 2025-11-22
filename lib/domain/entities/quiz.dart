import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

@freezed
class Question with _$Question {
  const Question._();

  const factory Question({
    required String id,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  /// Validates that the question has exactly 4 options
  bool get isValid => options.length == 4 && correctOptionIndex >= 0 && correctOptionIndex < 4;
}

@freezed
class Quiz with _$Quiz {
  const Quiz._();

  const factory Quiz({
    required String id,
    required String title,
    required String description,
    required String teacherId,
    required String pin,
    int? timeLimitMinutes,
    required List<Question> questions,
    required DateTime createdAt,
    @Default(true) bool isActive,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  /// Validates quiz data integrity
  bool get isValid {
    // Check if title is not empty
    if (title.trim().isEmpty) return false;

    // Check if PIN is not empty
    if (pin.trim().isEmpty) return false;

    // Check if there's at least one question
    if (questions.isEmpty) return false;

    // Check if all questions are valid
    if (!questions.every((q) => q.isValid)) return false;

    // Check if time limit is positive when provided
    if (timeLimitMinutes != null && timeLimitMinutes! <= 0) return false;

    return true;
  }

  /// Returns the total number of questions in the quiz
  int get totalQuestions => questions.length;
}
