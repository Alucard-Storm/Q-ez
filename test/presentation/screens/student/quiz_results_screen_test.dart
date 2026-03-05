import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/domain/entities/quiz_attempt.dart';
import 'package:q_ez/domain/entities/quiz.dart';
import 'package:q_ez/domain/entities/user.dart';
import 'package:q_ez/presentation/providers/auth_providers.dart';
import 'package:q_ez/presentation/providers/quiz_providers.dart';
import 'package:q_ez/presentation/screens/student/quiz_results_screen.dart';

void main() {
  group('QuizResultsScreen', () {
    late QuizAttempt mockAttempt;
    late Quiz mockQuiz;
    late User mockUser;

    setUp(() {
      mockUser = User(
        id: 'user1',
        email: 'student@test.com',
        name: 'Test Student',
        role: UserRole.student,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      mockQuiz = Quiz(
        id: 'quiz1',
        title: 'Test Quiz',
        description: 'A test quiz',
        teacherId: 'teacher1',
        pin: '123456',
        timeLimitMinutes: 30,
        questions: [
          const Question(
            id: 'q1',
            text: 'What is 2+2?',
            options: ['3', '4', '5', '6'],
            correctOptionIndex: 1,
          ),
          const Question(
            id: 'q2',
            text: 'What is the capital of France?',
            options: ['London', 'Berlin', 'Paris', 'Madrid'],
            correctOptionIndex: 2,
          ),
        ],
        createdAt: DateTime.now(),
      );

      mockAttempt = QuizAttempt(
        id: 'attempt1',
        studentId: 'user1',
        quizId: 'quiz1',
        answers: {'q1': 1, 'q2': 2}, // Both correct
        score: 2.0,
        totalQuestions: 2,
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        completedAt: DateTime.now(),
        securityViolations: 0,
        violations: const [],
        isFlagged: false,
      );
    });

    testWidgets('displays quiz results with passing score', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attemptByIdProvider('attempt1').overrideWith((ref) async => mockAttempt),
            quizByIdProvider('quiz1').overrideWith((ref) async => mockQuiz),
            currentUserProvider.overrideWith((ref) async => mockUser),
          ],
          child: const MaterialApp(
            home: QuizResultsScreen(attemptId: 'attempt1'),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify score is displayed
      expect(find.text('100.0%'), findsOneWidget);
      expect(find.text('PASSED'), findsOneWidget);
      expect(find.text('2 out of 2 correct'), findsOneWidget);

      // Verify action buttons are present
      expect(find.text('Return to Home'), findsOneWidget);
      expect(find.text('View Leaderboard'), findsOneWidget);
    });

    testWidgets('displays quiz results with failing score', (WidgetTester tester) async {
      // Create a failing attempt
      final failingAttempt = mockAttempt.copyWith(
        answers: {'q1': 0, 'q2': 1}, // Both incorrect
        score: 0.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attemptByIdProvider('attempt1').overrideWith((ref) async => failingAttempt),
            quizByIdProvider('quiz1').overrideWith((ref) async => mockQuiz),
            currentUserProvider.overrideWith((ref) async => mockUser),
          ],
          child: const MaterialApp(
            home: QuizResultsScreen(attemptId: 'attempt1'),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify score is displayed
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('FAILED'), findsOneWidget);
      expect(find.text('0 out of 2 correct'), findsOneWidget);
    });

    testWidgets('displays answer breakdown correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attemptByIdProvider('attempt1').overrideWith((ref) async => mockAttempt),
            quizByIdProvider('quiz1').overrideWith((ref) async => mockQuiz),
            currentUserProvider.overrideWith((ref) async => mockUser),
          ],
          child: const MaterialApp(
            home: QuizResultsScreen(attemptId: 'attempt1'),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify answer breakdown section
      expect(find.text('Answer Breakdown'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
    });

    testWidgets('displays detailed answer review', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attemptByIdProvider('attempt1').overrideWith((ref) async => mockAttempt),
            quizByIdProvider('quiz1').overrideWith((ref) async => mockQuiz),
            currentUserProvider.overrideWith((ref) async => mockUser),
          ],
          child: const MaterialApp(
            home: QuizResultsScreen(attemptId: 'attempt1'),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify detailed answer review section
      expect(find.text('Detailed Answer Review'), findsOneWidget);
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.text('What is 2+2?'), findsOneWidget);
      expect(find.text('What is the capital of France?'), findsOneWidget);
    });
  });
}