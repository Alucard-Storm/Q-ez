import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Firebase implementation of QuizRepository
/// Handles quiz CRUD operations with Firestore
class FirebaseQuizRepository implements QuizRepository {
  final FirebaseFirestore _firestore;

  FirebaseQuizRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Quiz> createQuiz(Quiz quiz) async {
    try {
      // Generate PIN if not provided
      String pin = quiz.pin.trim();
      if (pin.isEmpty) {
        pin = await generateUniquePin();
      } else {
        // Validate PIN uniqueness
        final isUnique = await isPinUnique(pin);
        if (!isUnique) {
          throw QuizException('PIN $pin is already in use');
        }
      }

      // Create quiz with generated/validated PIN
      final quizWithPin = quiz.copyWith(pin: pin);

      // Validate quiz data
      if (!quizWithPin.isValid) {
        throw QuizException('Invalid quiz data');
      }

      // Create document reference
      final docRef = _firestore.collection(FirestoreConstants.quizzesCollection).doc();

      // Build quiz data
      final quizData = _quizToMap(quizWithPin.copyWith(id: docRef.id));

      // Save to Firestore
      await docRef.set(quizData);

      return quizWithPin.copyWith(id: docRef.id);
    } catch (e) {
      if (e is QuizException) rethrow;
      throw QuizException('Failed to create quiz: ${e.toString()}');
    }
  }

  @override
  Future<Quiz> getQuizByPin(String pin) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .where(FirestoreConstants.quizPin, isEqualTo: pin)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw QuizNotFoundException('PIN: $pin');
      }

      return _quizFromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      if (e is QuizNotFoundException) rethrow;
      throw QuizException('Failed to get quiz by PIN: ${e.toString()}');
    }
  }

  @override
  Future<Quiz> getQuizById(String id) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw QuizNotFoundException('ID: $id');
      }

      return _quizFromSnapshot(docSnapshot);
    } catch (e) {
      if (e is QuizNotFoundException) rethrow;
      throw QuizException('Failed to get quiz by ID: ${e.toString()}');
    }
  }

  @override
  Future<List<Quiz>> getQuizzesByTeacher(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .where(FirestoreConstants.quizTeacherId, isEqualTo: teacherId)
          .orderBy(FirestoreConstants.quizCreatedAt, descending: true)
          .get();

      return querySnapshot.docs.map(_quizFromSnapshot).toList();
    } catch (e) {
      throw QuizException('Failed to get quizzes by teacher: ${e.toString()}');
    }
  }

  @override
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .orderBy(FirestoreConstants.quizCreatedAt, descending: true)
          .get();

      return querySnapshot.docs.map(_quizFromSnapshot).toList();
    } catch (e) {
      throw QuizException('Failed to get all quizzes: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuiz(Quiz quiz) async {
    try {
      // Check if quiz exists
      final docRef = _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .doc(quiz.id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw QuizNotFoundException('ID: ${quiz.id}');
      }

      // If PIN is being changed, validate uniqueness
      final existingData = docSnapshot.data()!;
      final existingPin = existingData[FirestoreConstants.quizPin] as String;

      if (quiz.pin != existingPin) {
        final isUnique = await isPinUnique(quiz.pin);
        if (!isUnique) {
          throw QuizException('PIN ${quiz.pin} is already in use');
        }
      }

      // Validate quiz data
      if (!quiz.isValid) {
        throw QuizException('Invalid quiz data');
      }

      // Update quiz
      final quizData = _quizToMap(quiz);
      await docRef.update(quizData);
    } catch (e) {
      if (e is QuizException || e is QuizNotFoundException) rethrow;
      throw QuizException('Failed to update quiz: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteQuiz(String id) async {
    try {
      // Check if quiz exists
      final docRef = _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .doc(id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw QuizNotFoundException('ID: $id');
      }

      // Delete all associated quiz attempts
      final attemptsSnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptQuizId, isEqualTo: id)
          .get();

      // Use batch to delete attempts and quiz
      final batch = _firestore.batch();

      for (final doc in attemptsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(docRef);

      await batch.commit();
    } catch (e) {
      if (e is QuizNotFoundException) rethrow;
      throw QuizException('Failed to delete quiz: ${e.toString()}');
    }
  }

  @override
  Stream<List<Quiz>> watchQuizzes() {
    return _firestore
        .collection(FirestoreConstants.quizzesCollection)
        .orderBy(FirestoreConstants.quizCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_quizFromSnapshot).toList());
  }

  @override
  Future<bool> isPinUnique(String pin) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.quizzesCollection)
          .where(FirestoreConstants.quizPin, isEqualTo: pin)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw QuizException('Failed to check PIN uniqueness: ${e.toString()}');
    }
  }

  @override
  Future<String> generateUniquePin() async {
    const maxAttempts = 10;
    final random = Random();

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // Generate 6-digit PIN
      final pin = (100000 + random.nextInt(900000)).toString();

      if (await isPinUnique(pin)) {
        return pin;
      }
    }

    throw QuizException('Failed to generate unique PIN after $maxAttempts attempts');
  }

  /// Convert Quiz entity to Firestore map
  Map<String, dynamic> _quizToMap(Quiz quiz) {
    return {
      FirestoreConstants.quizId: quiz.id,
      FirestoreConstants.quizTitle: quiz.title,
      FirestoreConstants.quizDescription: quiz.description,
      FirestoreConstants.quizTeacherId: quiz.teacherId,
      FirestoreConstants.quizPin: quiz.pin,
      FirestoreConstants.quizTimeLimitMinutes: quiz.timeLimitMinutes,
      FirestoreConstants.quizCreatedAt: Timestamp.fromDate(quiz.createdAt),
      FirestoreConstants.quizIsActive: quiz.isActive,
      FirestoreConstants.quizQuestions: quiz.questions.map(_questionToMap).toList(),
    };
  }

  /// Convert Question entity to Firestore map
  Map<String, dynamic> _questionToMap(Question question) {
    return {
      FirestoreConstants.questionId: question.id,
      FirestoreConstants.questionText: question.text,
      FirestoreConstants.questionOptions: question.options,
      FirestoreConstants.questionCorrectOptionIndex: question.correctOptionIndex,
    };
  }

  /// Convert Firestore document to Quiz entity
  Quiz _quizFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Quiz(
      id: snapshot.id,
      title: data[FirestoreConstants.quizTitle] as String,
      description: data[FirestoreConstants.quizDescription] as String,
      teacherId: data[FirestoreConstants.quizTeacherId] as String,
      pin: data[FirestoreConstants.quizPin] as String,
      timeLimitMinutes: data[FirestoreConstants.quizTimeLimitMinutes] as int?,
      createdAt: (data[FirestoreConstants.quizCreatedAt] as Timestamp).toDate(),
      isActive: data[FirestoreConstants.quizIsActive] as bool? ?? true,
      questions: (data[FirestoreConstants.quizQuestions] as List)
          .map((q) => _questionFromMap(q as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert Firestore map to Question entity
  Question _questionFromMap(Map<String, dynamic> data) {
    return Question(
      id: data[FirestoreConstants.questionId] as String,
      text: data[FirestoreConstants.questionText] as String,
      options: List<String>.from(data[FirestoreConstants.questionOptions]),
      correctOptionIndex: data[FirestoreConstants.questionCorrectOptionIndex] as int,
    );
  }
}
