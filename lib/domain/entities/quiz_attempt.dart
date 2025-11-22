import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_attempt.freezed.dart';
part 'quiz_attempt.g.dart';

enum SecurityViolationType {
  tabSwitch,
  appSwitch,
  copyAttempt,
}

@freezed
class SecurityViolation with _$SecurityViolation {
  const factory SecurityViolation({
    required SecurityViolationType type,
    required DateTime timestamp,
  }) = _SecurityViolation;

  factory SecurityViolation.fromJson(Map<String, dynamic> json) =>
      _$SecurityViolationFromJson(json);
}

@freezed
class QuizAttempt with _$QuizAttempt {
  const QuizAttempt._();

  const factory QuizAttempt({
    required String id,
    required String studentId,
    required String quizId,
    required Map<String, int> answers,
    required double score,
    required int totalQuestions,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0) int securityViolations,
    @Default([]) List<SecurityViolation> violations,
    @Default(false) bool isFlagged,
  }) = _QuizAttempt;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptFromJson(json);

  /// Returns true if the quiz attempt is completed
  bool get isCompleted => completedAt != null;

  /// Returns the percentage score
  double get scorePercentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  /// Returns true if the attempt should be auto-submitted due to violations
  bool get shouldAutoSubmit => securityViolations >= 3;

  /// Returns the duration of the quiz attempt
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }
}
