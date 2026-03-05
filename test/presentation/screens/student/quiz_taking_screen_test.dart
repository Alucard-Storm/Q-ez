import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/presentation/screens/student/quiz_taking_screen.dart';

void main() {
  group('QuizTakingScreen', () {
    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: QuizTakingScreen(quizId: 'test-quiz-id'),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display quiz taking screen title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: QuizTakingScreen(quizId: 'test-quiz-id'),
          ),
        ),
      );

      // Should have a scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}