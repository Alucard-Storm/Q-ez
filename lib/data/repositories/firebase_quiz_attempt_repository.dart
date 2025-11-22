import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/repositories/quiz_attempt_repository.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Firebase implementation of QuizAttemptRepository
/// Handles quiz attempt lifecycle and security violation tracking
class FirebaseQuizAttemptRepository implements QuizAttemptRepository {
  final FirebaseFirestore _firestore;
  final QuizRepository _quizRepository;

  FirebaseQuizAttemptRepository({
    FirebaseFirestore? firestore,
    required QuizRepository quizRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _quizRepository = quizRepository;

  @override
  Future<QuizAttempt> startAttempt(String studentId, String quizId) async {
    try {
      // Verify quiz exists and get question count
      final quiz = await _quizRepository.getQuizById(quizId);

      // Create new attempt
      final docRef = _firestore.collection(FirestoreConstants.quizAttemptsCollection).doc();
      final now = DateTime.now();

      final attempt = QuizAttempt(
        id: docRef.id,
        studentId: studentId,
        quizId: quizId,
        answers: {},
        score: 0.0,
        totalQuestions: quiz.totalQuestions,
        startedAt: now,
        completedAt: null,
        securityViolations: 0,
        violations: [],
        isFlagged: false,
      );

      final attemptData = _attemptToMap(attempt);
      await docRef.set(attemptData);

      return attempt;
    } catch (e) {
      if (e is QuizNotFoundException) rethrow;
      throw QuizAttemptException('Failed to start attempt: ${e.toString()}');
    }
  }

  @override
  Future<void> submitAnswer(
    String attemptId,
    String questionId,
    int selectedOption,
  ) async {
    try {
      final docRef = _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .doc(attemptId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw QuizAttemptNotFoundException(attemptId);
      }

      final data = docSnapshot.data()!;

      // Check if attempt is already completed
      if (data[FirestoreConstants.attemptCompletedAt] != null) {
        throw QuizAttemptException('Cannot submit answer: Attempt already completed');
      }

      // Update answers map
      await docRef.update({
        '${FirestoreConstants.attemptAnswers}.$questionId': selectedOption,
      });
    } catch (e) {
      if (e is QuizAttemptException || e is QuizAttemptNotFoundException) rethrow;
      throw QuizAttemptException('Failed to submit answer: ${e.toString()}');
    }
  }

  @override
  Future<QuizAttempt> completeAttempt(String attemptId) async {
    try {
      final docRef = _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .doc(attemptId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw QuizAttemptNotFoundException(attemptId);
      }

      final data = docSnapshot.data()!;

      // Check if already completed
      if (data[FirestoreConstants.attemptCompletedAt] != null) {
        throw QuizAttemptException('Attempt already completed');
      }

      // Get quiz to calculate score
      final quizId = data[FirestoreConstants.attemptQuizId] as String;
      final quiz = await _quizRepository.getQuizById(quizId);

      // Calculate score
      final answers = Map<String, int>.from(
        data[FirestoreConstants.attemptAnswers] as Map? ?? {},
      );
      final score = _calculateScore(quiz, answers);

      // Update attempt with completion data
      final now = DateTime.now();
      await docRef.update({
        FirestoreConstants.attemptScore: score,
        FirestoreConstants.attemptCompletedAt: Timestamp.fromDate(now),
      });

      // Fetch and return updated attempt
      final updatedSnapshot = await docRef.get();
      return _attemptFromSnapshot(updatedSnapshot);
    } catch (e) {
      if (e is QuizAttemptException || e is QuizAttemptNotFoundException) rethrow;
      throw QuizAttemptException('Failed to complete attempt: ${e.toString()}');
    }
  }

  @override
  Future<void> recordViolation(
    String attemptId,
    SecurityViolationType type,
  ) async {
    try {
      final docRef = _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .doc(attemptId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw QuizAttemptNotFoundException(attemptId);
      }

      final data = docSnapshot.data()!;

      // Check if already completed
      if (data[FirestoreConstants.attemptCompletedAt] != null) {
        throw QuizAttemptException('Cannot record violation: Attempt already completed');
      }

      // Create violation record
      final violation = SecurityViolation(
        type: type,
        timestamp: DateTime.now(),
      );

      // Get current violation count
      final currentViolations = data[FirestoreConstants.attemptSecurityViolations] as int? ?? 0;
      final newViolationCount = currentViolations + 1;

      // Update attempt with new violation
      await docRef.update({
        FirestoreConstants.attemptSecurityViolations: newViolationCount,
        FirestoreConstants.attemptViolations: FieldValue.arrayUnion([
          _violationToMap(violation),
        ]),
        // Flag if violations reach threshold
        if (newViolationCount >= FirestoreConstants.maxSecurityViolations)
          FirestoreConstants.attemptIsFlagged: true,
      });

      // Auto-submit if violations reach threshold
      if (newViolationCount >= FirestoreConstants.maxSecurityViolations) {
        await completeAttempt(attemptId);
      }
    } catch (e) {
      if (e is QuizAttemptException || e is QuizAttemptNotFoundException) rethrow;
      throw QuizAttemptException('Failed to record violation: ${e.toString()}');
    }
  }

  @override
  Future<QuizAttempt> getAttempt(String attemptId) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .doc(attemptId)
          .get();

      if (!docSnapshot.exists) {
        throw QuizAttemptNotFoundException(attemptId);
      }

      return _attemptFromSnapshot(docSnapshot);
    } catch (e) {
      if (e is QuizAttemptNotFoundException) rethrow;
      throw QuizAttemptException('Failed to get attempt: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizAttempt>> getStudentAttempts(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptStudentId, isEqualTo: studentId)
          .orderBy(FirestoreConstants.attemptStartedAt, descending: true)
          .get();

      return querySnapshot.docs.map(_attemptFromSnapshot).toList();
    } catch (e) {
      throw QuizAttemptException('Failed to get student attempts: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizAttempt>> getQuizAttempts(String quizId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptQuizId, isEqualTo: quizId)
          .orderBy(FirestoreConstants.attemptScore, descending: true)
          .get();

      return querySnapshot.docs.map(_attemptFromSnapshot).toList();
    } catch (e) {
      throw QuizAttemptException('Failed to get quiz attempts: ${e.toString()}');
    }
  }

  @override
  Stream<QuizAttempt> watchAttempt(String attemptId) {
    return _firestore
        .collection(FirestoreConstants.quizAttemptsCollection)
        .doc(attemptId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw QuizAttemptNotFoundException(attemptId);
      }
      return _attemptFromSnapshot(snapshot);
    });
  }

  @override
  Future<QuizAttempt?> getActiveAttempt(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptStudentId, isEqualTo: studentId)
          .where(FirestoreConstants.attemptCompletedAt, isNull: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return _attemptFromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      throw QuizAttemptException('Failed to get active attempt: ${e.toString()}');
    }
  }

  /// Calculate score based on correct answers
  double _calculateScore(Quiz quiz, Map<String, int> answers) {
    int correctCount = 0;

    for (final question in quiz.questions) {
      final selectedOption = answers[question.id];
      if (selectedOption != null && selectedOption == question.correctOptionIndex) {
        correctCount++;
      }
    }

    return correctCount.toDouble();
  }

  /// Convert QuizAttempt entity to Firestore map
  Map<String, dynamic> _attemptToMap(QuizAttempt attempt) {
    return {
      FirestoreConstants.attemptId: attempt.id,
      FirestoreConstants.attemptStudentId: attempt.studentId,
      FirestoreConstants.attemptQuizId: attempt.quizId,
      FirestoreConstants.attemptAnswers: attempt.answers,
      FirestoreConstants.attemptScore: attempt.score,
      FirestoreConstants.attemptTotalQuestions: attempt.totalQuestions,
      FirestoreConstants.attemptStartedAt: Timestamp.fromDate(attempt.startedAt),
      FirestoreConstants.attemptCompletedAt:
          attempt.completedAt != null ? Timestamp.fromDate(attempt.completedAt!) : null,
      FirestoreConstants.attemptSecurityViolations: attempt.securityViolations,
      FirestoreConstants.attemptViolations:
          attempt.violations.map(_violationToMap).toList(),
      FirestoreConstants.attemptIsFlagged: attempt.isFlagged,
    };
  }

  /// Convert SecurityViolation entity to Firestore map
  Map<String, dynamic> _violationToMap(SecurityViolation violation) {
    return {
      FirestoreConstants.violationType: _violationTypeToString(violation.type),
      FirestoreConstants.violationTimestamp: Timestamp.fromDate(violation.timestamp),
    };
  }

  /// Convert Firestore document to QuizAttempt entity
  QuizAttempt _attemptFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return QuizAttempt(
      id: snapshot.id,
      studentId: data[FirestoreConstants.attemptStudentId] as String,
      quizId: data[FirestoreConstants.attemptQuizId] as String,
      answers: Map<String, int>.from(data[FirestoreConstants.attemptAnswers] as Map? ?? {}),
      score: (data[FirestoreConstants.attemptScore] as num).toDouble(),
      totalQuestions: data[FirestoreConstants.attemptTotalQuestions] as int,
      startedAt: (data[FirestoreConstants.attemptStartedAt] as Timestamp).toDate(),
      completedAt: data[FirestoreConstants.attemptCompletedAt] != null
          ? (data[FirestoreConstants.attemptCompletedAt] as Timestamp).toDate()
          : null,
      securityViolations: data[FirestoreConstants.attemptSecurityViolations] as int? ?? 0,
      violations: (data[FirestoreConstants.attemptViolations] as List?)
              ?.map((v) => _violationFromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
      isFlagged: data[FirestoreConstants.attemptIsFlagged] as bool? ?? false,
    );
  }

  /// Convert Firestore map to SecurityViolation entity
  SecurityViolation _violationFromMap(Map<String, dynamic> data) {
    return SecurityViolation(
      type: _parseViolationType(data[FirestoreConstants.violationType] as String),
      timestamp: (data[FirestoreConstants.violationTimestamp] as Timestamp).toDate(),
    );
  }

  /// Convert SecurityViolationType to string
  String _violationTypeToString(SecurityViolationType type) {
    switch (type) {
      case SecurityViolationType.tabSwitch:
        return FirestoreConstants.violationTypeTabSwitch;
      case SecurityViolationType.appSwitch:
        return FirestoreConstants.violationTypeAppSwitch;
      case SecurityViolationType.copyAttempt:
        return FirestoreConstants.violationTypeCopyAttempt;
    }
  }

  /// Parse SecurityViolationType from string
  SecurityViolationType _parseViolationType(String typeString) {
    switch (typeString) {
      case FirestoreConstants.violationTypeTabSwitch:
        return SecurityViolationType.tabSwitch;
      case FirestoreConstants.violationTypeAppSwitch:
        return SecurityViolationType.appSwitch;
      case FirestoreConstants.violationTypeCopyAttempt:
        return SecurityViolationType.copyAttempt;
      default:
        throw QuizAttemptException('Invalid violation type: $typeString');
    }
  }
}
