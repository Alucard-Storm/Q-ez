import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/security_monitor.dart';
import '../../data/repositories/firebase_quiz_attempt_repository.dart';
import '../../data/repositories/firebase_quiz_repository.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/repositories/quiz_attempt_repository.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Provider for QuizRepository dependency injection
/// Provides access to quiz CRUD operations throughout the app
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return FirebaseQuizRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for QuizAttemptRepository dependency injection
/// Provides access to quiz attempt lifecycle operations
final attemptRepositoryProvider = Provider<QuizAttemptRepository>((ref) {
  return FirebaseQuizAttemptRepository(
    firestore: FirebaseFirestore.instance,
    quizRepository: ref.watch(quizRepositoryProvider),
  );
});

/// StateNotifier for managing active quiz attempt state
/// Handles quiz taking flow including answer submission and completion
class ActiveAttemptNotifier extends StateNotifier<QuizAttempt?> {
  final QuizAttemptRepository _repository;
  StreamSubscription<QuizAttempt>? _attemptSubscription;

  ActiveAttemptNotifier(this._repository) : super(null);

  /// Start a new quiz attempt
  Future<void> startAttempt(String studentId, String quizId) async {
    try {
      final attempt = await _repository.startAttempt(studentId, quizId);
      state = attempt;
      
      // Watch for real-time updates
      _attemptSubscription?.cancel();
      _attemptSubscription = _repository.watchAttempt(attempt.id).listen(
        (updatedAttempt) {
          state = updatedAttempt;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Submit an answer for a specific question
  Future<void> submitAnswer(String questionId, int selectedOption) async {
    if (state == null) return;
    
    try {
      await _repository.submitAnswer(state!.id, questionId, selectedOption);
      // State will be updated via the stream subscription
    } catch (e) {
      rethrow;
    }
  }

  /// Record a security violation
  Future<void> recordViolation(SecurityViolationType type) async {
    if (state == null) return;
    
    try {
      await _repository.recordViolation(state!.id, type);
      // State will be updated via the stream subscription
    } catch (e) {
      rethrow;
    }
  }

  /// Complete the quiz attempt
  Future<QuizAttempt> completeAttempt() async {
    if (state == null) {
      throw Exception('No active attempt to complete');
    }
    
    try {
      final completedAttempt = await _repository.completeAttempt(state!.id);
      state = completedAttempt;
      _attemptSubscription?.cancel();
      return completedAttempt;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear the active attempt
  void clearAttempt() {
    _attemptSubscription?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _attemptSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for active quiz attempt state
/// Manages the current quiz being taken by a student
final activeAttemptProvider =
    StateNotifierProvider<ActiveAttemptNotifier, QuizAttempt?>((ref) {
  final repository = ref.watch(attemptRepositoryProvider);
  return ActiveAttemptNotifier(repository);
});

/// StateNotifier for managing quiz countdown timer
/// Handles time tracking during quiz attempts
class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  VoidCallback? onTimeUp;

  TimerNotifier(super.totalSeconds, {this.onTimeUp});

  /// Start the countdown timer
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 0) {
        timer.cancel();
        onTimeUp?.call();
      } else {
        state = state - 1;
      }
    });
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
  }

  /// Resume the timer
  void resume() {
    if (state > 0) {
      start();
    }
  }

  /// Stop and reset the timer
  void stop() {
    _timer?.cancel();
    state = 0;
  }

  /// Get remaining time in minutes and seconds
  String get formattedTime {
    final minutes = state ~/ 60;
    final seconds = state % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider family for quiz timer
/// Creates a timer for a specific quiz duration
/// Usage: ref.watch(timerProvider(durationInMinutes))
final timerProvider = StateNotifierProvider.family<TimerNotifier, int, int>(
  (ref, durationInMinutes) {
    final totalSeconds = durationInMinutes * 60;
    return TimerNotifier(totalSeconds);
  },
);

/// Provider for security monitor
/// Manages anti-cheating system during quiz attempts
final securityMonitorProvider = Provider<SecurityMonitor>((ref) {
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  return SecurityMonitor(
    attemptRepository: attemptRepository,
    violationThreshold: 3,
  );
});

/// Provider for getting a quiz by PIN
/// Usage: ref.watch(quizByPinProvider(pin))
final quizByPinProvider = FutureProvider.family<Quiz, String>((ref, pin) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizByPin(pin);
});

/// Provider for getting a quiz by ID
/// Usage: ref.watch(quizByIdProvider(id))
final quizByIdProvider = FutureProvider.family<Quiz, String>((ref, id) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizById(id);
});

/// Provider for watching all quizzes (real-time)
/// Useful for teacher and admin dashboards
final quizzesStreamProvider = StreamProvider<List<Quiz>>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.watchQuizzes();
});

/// Provider for getting quizzes by teacher ID
/// Usage: ref.watch(quizzesByTeacherProvider(teacherId))
final quizzesByTeacherProvider =
    FutureProvider.family<List<Quiz>, String>((ref, teacherId) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizzesByTeacher(teacherId);
});

/// Provider for getting a quiz attempt by ID
/// Usage: ref.watch(attemptByIdProvider(attemptId))
final attemptByIdProvider = FutureProvider.family<QuizAttempt, String>((ref, attemptId) async {
  final repository = ref.watch(attemptRepositoryProvider);
  return repository.getAttempt(attemptId);
});
