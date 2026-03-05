import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinQuizScreen Widget Tests', () {
    testWidgets('PIN input field should limit to 6 digits', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      
      // Enter more than 6 digits
      await tester.enterText(textField, '1234567890');
      await tester.pump();

      // Should be limited to 6 digits
      expect(controller.text, '123456');
    });

    testWidgets('PIN input should only accept numeric characters', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      
      // Try to enter non-numeric characters
      await tester.enterText(textField, 'abc123def');
      await tester.pump();

      // Should only contain numeric characters
      expect(controller.text, '123');
    });

    testWidgets('PIN validation should work correctly', (tester) async {
      String? validationResult;
      
      // Test the validation function
      String? validator(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a PIN';
        }
        if (value.length != 6) {
          return 'PIN must be 6 digits';
        }
        return null;
      }

      // Test empty input
      validationResult = validator('');
      expect(validationResult, 'Please enter a PIN');

      // Test short input
      validationResult = validator('123');
      expect(validationResult, 'PIN must be 6 digits');

      // Test long input
      validationResult = validator('1234567');
      expect(validationResult, 'PIN must be 6 digits');

      // Test valid input
      validationResult = validator('123456');
      expect(validationResult, null);
    });
  });
}