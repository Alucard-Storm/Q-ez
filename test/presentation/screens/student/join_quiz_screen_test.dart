import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/presentation/screens/student/join_quiz_screen.dart';

void main() {
  group('JoinQuizScreen', () {
    testWidgets('should display PIN input field and header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const JoinQuizScreen(),
          ),
        ),
      );

      // Verify header elements
      expect(find.text('Enter Quiz PIN'), findsOneWidget);
      expect(find.text('Enter the 6-digit PIN provided by your teacher'), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsOneWidget);

      // Verify PIN input field
      expect(find.text('Quiz PIN'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Verify buttons
      expect(find.text('Find Quiz'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('should validate PIN input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const JoinQuizScreen(),
          ),
        ),
      );

      final findQuizButton = find.text('Find Quiz');
      
      // Tap Find Quiz without entering PIN
      await tester.tap(findQuizButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a PIN'), findsOneWidget);
    });

    testWidgets('should limit PIN input to 6 digits', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const JoinQuizScreen(),
          ),
        ),
      );

      final pinField = find.byType(TextFormField);
      
      // Enter more than 6 digits
      await tester.enterText(pinField, '1234567890');
      await tester.pump();

      // Should be limited to 6 digits
      final textField = tester.widget<TextFormField>(pinField);
      expect(textField.controller?.text, '123456');
    });

    testWidgets('should only accept numeric input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const JoinQuizScreen(),
          ),
        ),
      );

      final pinField = find.byType(TextFormField);
      
      // Try to enter non-numeric characters
      await tester.enterText(pinField, 'abc123');
      await tester.pump();

      // Should only contain numeric characters
      final textField = tester.widget<TextFormField>(pinField);
      expect(textField.controller?.text, '123');
    });
  });
}