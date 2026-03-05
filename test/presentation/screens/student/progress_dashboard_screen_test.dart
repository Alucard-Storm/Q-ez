import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/presentation/screens/student/progress_dashboard_screen.dart';

void main() {
  group('ProgressDashboardScreen', () {
    testWidgets('displays progress dashboard screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProgressDashboardScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify the app bar title is displayed
      expect(find.text('Progress Dashboard'), findsOneWidget);
      
      // Verify the filter button is displayed
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('displays filter options when filter button is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProgressDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap on filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify filter options are displayed
      expect(find.text('Last 10 Quizzes'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });

    testWidgets('shows filter indicator', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProgressDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify filter indicator is displayed with default filter
      expect(find.text('Showing: All Time'), findsOneWidget);
    });

    testWidgets('can change filter selection', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProgressDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap on filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select "Last 10 Quizzes" filter
      await tester.tap(find.text('Last 10 Quizzes'));
      await tester.pumpAndSettle();

      // Verify filter indicator is updated
      expect(find.text('Showing: Last 10 Quizzes'), findsOneWidget);
    });
  });
}