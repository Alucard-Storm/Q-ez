import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/quiz/create_quiz_use_case.dart';
import '../../domain/usecases/quiz/update_quiz_use_case.dart';
import '../../domain/usecases/quiz/delete_quiz_use_case.dart';
import 'auth_providers.dart';
import 'quiz_providers.dart';

/// Provider for CreateQuizUseCase
final createQuizUseCaseProvider = Provider<CreateQuizUseCase>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  return CreateQuizUseCase(quizRepository);
});

/// Provider for UpdateQuizUseCase
final updateQuizUseCaseProvider = Provider<UpdateQuizUseCase>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateQuizUseCase(quizRepository, authRepository);
});

/// Provider for DeleteQuizUseCase
final deleteQuizUseCaseProvider = Provider<DeleteQuizUseCase>((ref) {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return DeleteQuizUseCase(quizRepository, authRepository);
});

/// Provider for getting teacher's quizzes
final teacherQuizzesProvider = FutureProvider.family<List<Quiz>, String>((ref, teacherId) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizzesByTeacher(teacherId);
});

/// Provider for quiz analytics data
final quizAnalyticsProvider = FutureProvider.family<QuizAnalyticsData, String>((ref, quizId) async {
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  final attempts = await attemptRepository.getQuizAttempts(quizId);
  
  return QuizAnalyticsData.fromAttempts(attempts);
});

/// Provider for teacher dashboard statistics
final teacherDashboardProvider = FutureProvider.family<TeacherDashboardData, String>((ref, teacherId) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  
  // Get teacher's quizzes
  final quizzes = await quizRepository.getQuizzesByTeacher(teacherId);
  
  // Get all attempts for teacher's quizzes
  final allAttempts = <QuizAttempt>[];
  for (final quiz in quizzes) {
    final attempts = await attemptRepository.getQuizAttempts(quiz.id);
    allAttempts.addAll(attempts);
  }
  
  return TeacherDashboardData.fromQuizzesAndAttempts(quizzes, allAttempts);
});

/// Data class for quiz analytics
class QuizAnalyticsData {
  final int totalAttempts;
  final double averageScore;
  final double passRate;
  final double completionRate;
  final List<QuizAttempt> topStudents;
  final Map<String, int> questionMissCount;
  final Map<int, int> scoreDistribution;
  final List<QuizAttempt> allAttempts;

  const QuizAnalyticsData({
    required this.totalAttempts,
    required this.averageScore,
    required this.passRate,
    required this.completionRate,
    required this.topStudents,
    required this.questionMissCount,
    required this.scoreDistribution,
    required this.allAttempts,
  });

  factory QuizAnalyticsData.fromAttempts(List<QuizAttempt> attempts) {
    final completedAttempts = attempts.where((a) => a.completedAt != null).toList();
    final totalAttempts = attempts.length;
    final completedCount = completedAttempts.length;
    
    if (completedAttempts.isEmpty) {
      return QuizAnalyticsData(
        totalAttempts: totalAttempts,
        averageScore: 0.0,
        passRate: 0.0,
        completionRate: totalAttempts > 0 ? completedCount / totalAttempts : 0.0,
        topStudents: [],
        questionMissCount: {},
        scoreDistribution: {},
        allAttempts: attempts,
      );
    }

    // Calculate average score
    final totalScore = completedAttempts.fold<double>(0.0, (sum, attempt) => sum + attempt.score);
    final averageScore = totalScore / completedCount;

    // Calculate pass rate (60% threshold)
    final passedCount = completedAttempts.where((a) => a.score >= 60.0).length;
    final passRate = passedCount / completedCount;

    // Calculate completion rate
    final completionRate = totalAttempts > 0 ? completedCount / totalAttempts : 0.0;

    // Get top 10 students
    final sortedAttempts = List<QuizAttempt>.from(completedAttempts);
    sortedAttempts.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;
      return a.completedAt!.compareTo(b.completedAt!);
    });
    final topStudents = sortedAttempts.take(10).toList();

    // Calculate question miss count (placeholder - would need question-level data)
    final questionMissCount = <String, int>{};

    // Calculate score distribution
    final scoreDistribution = <int, int>{};
    for (final attempt in completedAttempts) {
      final scoreRange = (attempt.score / 10).floor() * 10;
      scoreDistribution[scoreRange] = (scoreDistribution[scoreRange] ?? 0) + 1;
    }

    return QuizAnalyticsData(
      totalAttempts: totalAttempts,
      averageScore: averageScore,
      passRate: passRate,
      completionRate: completionRate,
      topStudents: topStudents,
      questionMissCount: questionMissCount,
      scoreDistribution: scoreDistribution,
      allAttempts: attempts,
    );
  }
}

/// Data class for teacher dashboard
class TeacherDashboardData {
  final int totalQuizzes;
  final int totalAttempts;
  final double averageScore;
  final List<Quiz> recentQuizzes;
  final List<QuizAttempt> recentActivity;

  const TeacherDashboardData({
    required this.totalQuizzes,
    required this.totalAttempts,
    required this.averageScore,
    required this.recentQuizzes,
    required this.recentActivity,
  });

  factory TeacherDashboardData.fromQuizzesAndAttempts(
    List<Quiz> quizzes,
    List<QuizAttempt> attempts,
  ) {
    final completedAttempts = attempts.where((a) => a.completedAt != null).toList();
    
    // Calculate average score
    double averageScore = 0.0;
    if (completedAttempts.isNotEmpty) {
      final totalScore = completedAttempts.fold<double>(0.0, (sum, attempt) => sum + attempt.score);
      averageScore = totalScore / completedAttempts.length;
    }

    // Get recent quizzes (last 5)
    final sortedQuizzes = List<Quiz>.from(quizzes);
    sortedQuizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentQuizzes = sortedQuizzes.take(5).toList();

    // Get recent activity (last 10 attempts)
    final sortedAttempts = List<QuizAttempt>.from(completedAttempts);
    sortedAttempts.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    final recentActivity = sortedAttempts.take(10).toList();

    return TeacherDashboardData(
      totalQuizzes: quizzes.length,
      totalAttempts: attempts.length,
      averageScore: averageScore,
      recentQuizzes: recentQuizzes,
      recentActivity: recentActivity,
    );
  }
}

/// StateNotifier for managing quiz creation form
class QuizFormNotifier extends StateNotifier<QuizFormState> {
  QuizFormNotifier() : super(QuizFormState.initial());

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updatePin(String pin) {
    state = state.copyWith(pin: pin);
  }

  void updateTimeLimit(int? timeLimit) {
    state = state.copyWith(timeLimit: timeLimit);
  }

  void addQuestion() {
    final newQuestion = QuestionFormData.empty();
    state = state.copyWith(
      questions: [...state.questions, newQuestion],
    );
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      final questions = List<QuestionFormData>.from(state.questions);
      questions.removeAt(index);
      state = state.copyWith(questions: questions);
    }
  }

  void updateQuestion(int index, QuestionFormData question) {
    if (index >= 0 && index < state.questions.length) {
      final questions = List<QuestionFormData>.from(state.questions);
      questions[index] = question;
      state = state.copyWith(questions: questions);
    }
  }

  void loadQuiz(Quiz quiz) {
    final questionForms = quiz.questions.map((q) => QuestionFormData(
      text: q.text,
      options: List<String>.from(q.options),
      correctOptionIndex: q.correctOptionIndex,
    )).toList();

    state = QuizFormState(
      title: quiz.title,
      description: quiz.description,
      pin: quiz.pin,
      timeLimit: quiz.timeLimitMinutes,
      questions: questionForms,
    );
  }

  void reset() {
    state = QuizFormState.initial();
  }

  Quiz toQuiz(String teacherId) {
    final questions = state.questions.map((q) => Question(
      id: DateTime.now().millisecondsSinceEpoch.toString() + state.questions.indexOf(q).toString(),
      text: q.text,
      options: q.options,
      correctOptionIndex: q.correctOptionIndex,
    )).toList();

    return Quiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: state.title,
      description: state.description,
      teacherId: teacherId,
      pin: state.pin,
      timeLimitMinutes: state.timeLimit,
      questions: questions,
      createdAt: DateTime.now(),
    );
  }

  bool get isValid {
    return state.title.trim().isNotEmpty &&
           state.questions.isNotEmpty &&
           state.questions.every((q) => q.isValid);
  }
}

/// Provider for quiz form state
final quizFormProvider = StateNotifierProvider<QuizFormNotifier, QuizFormState>((ref) {
  return QuizFormNotifier();
});

/// State class for quiz form
class QuizFormState {
  final String title;
  final String description;
  final String pin;
  final int? timeLimit;
  final List<QuestionFormData> questions;

  const QuizFormState({
    required this.title,
    required this.description,
    required this.pin,
    required this.timeLimit,
    required this.questions,
  });

  factory QuizFormState.initial() {
    return const QuizFormState(
      title: '',
      description: '',
      pin: '',
      timeLimit: null,
      questions: [],
    );
  }

  QuizFormState copyWith({
    String? title,
    String? description,
    String? pin,
    int? timeLimit,
    List<QuestionFormData>? questions,
  }) {
    return QuizFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      pin: pin ?? this.pin,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
    );
  }
}

/// Data class for question form
class QuestionFormData {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  const QuestionFormData({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuestionFormData.empty() {
    return const QuestionFormData(
      text: '',
      options: ['', '', '', ''],
      correctOptionIndex: 0,
    );
  }

  QuestionFormData copyWith({
    String? text,
    List<String>? options,
    int? correctOptionIndex,
  }) {
    return QuestionFormData(
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
    );
  }

  bool get isValid {
    return text.trim().isNotEmpty &&
           options.length == 4 &&
           options.every((option) => option.trim().isNotEmpty) &&
           correctOptionIndex >= 0 &&
           correctOptionIndex < 4;
  }
}