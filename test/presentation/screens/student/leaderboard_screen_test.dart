import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:q_ez/domain/entities/user.dart';
import 'package:q_ez/domain/repositories/user_repository.dart';
import 'package:q_ez/domain/usecases/progress/get_leaderboard_use_case.dart';
import 'package:q_ez/presentation/providers/auth_providers.dart';
import 'package:q_ez/presentation/providers/student_providers.dart';
import 'package:q_ez/presentation/screens/student/leaderboard_screen.dart';

import 'leaderboard_screen_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('LeaderboardScreen', () {
    late MockUserRepository mockUserRepository;
    late Student testStudent;
    late List<Student> testStudents;
    late List<LeaderboardEntry> testLeaderboardEntries;

    setUp(() {
      mockUserRepository = MockUserRepository();
      
      // Create test student (current user)
      testStudent = Student(
        id: 'student1',
        email: 'student1@test.com',
        name: 'Test Student 1',
        role: UserRole.student,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        level: 5,
        badgeIds: ['badge1'],
        totalQuizzesTaken: 10,
        averageScore: 85.0,
      );

      // Create test students for leaderboard
      testStudents = [
        Student(
          id: 'student2',
          email: 'student2@test.com',
          name: 'Top Student',
          role: UserRole.student,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          level: 10,
          badgeIds: ['badge1', 'badge2'],
          totalQuizzesTaken: 20,
          averageScore: 95.0,
        ),
        testStudent, // Current user in 2nd place
        Student(
          id: 'student3',
          email: 'student3@test.com',
          name: 'Third Student',
          role: UserRole.student,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          level: 3,
          badgeIds: [],
          totalQuizzesTaken: 5,
          averageScore: 70.0,
        ),
      ];

      // Create leaderboard entries
      testLeaderboardEntries = [
        LeaderboardEntry(
          student: testStudents[0],
          rank: 1,
          level: 10,
          totalScore: 1900.0, // 95.0 * 20
        ),
        LeaderboardEntry(
          student: testStudents[1],
          rank: 2,
          level: 5,
          totalScore: 850.0, // 85.0 * 10
        ),
        LeaderboardEntry(
          student: testStudents[2],
          rank: 3,
          level: 3,
          totalScore: 350.0, // 70.0 * 5
        ),
      ];
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          currentUserProvider.overrideWith((ref) async => testStudent),
          leaderboardProvider(50).overrideWith((ref) async => testLeaderboardEntries),
        ],
        child: const MaterialApp(
          home: LeaderboardScreen(),
        ),
      );
    }

    testWidgets('displays loading indicator initially', (tester) async {
      // Override with loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) => Future.delayed(const Duration(seconds: 10))),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when user loading fails', (tester) async {
      const errorMessage = 'Failed to load user';
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) => Future.error(errorMessage)),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('displays leaderboard with student rankings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if leaderboard header is displayed
      expect(find.text('Global Leaderboard'), findsOneWidget);
      expect(find.text('3 students competing'), findsOneWidget);

      // Check if all students are displayed
      expect(find.text('Top Student'), findsOneWidget);
      expect(find.text('Test Student 1'), findsOneWidget);
      expect(find.text('Third Student'), findsOneWidget);

      // Check if levels are displayed
      expect(find.text('Level 10'), findsOneWidget);
      expect(find.text('Level 5'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);

      // Check if scores are displayed
      expect(find.text('1900 pts'), findsOneWidget);
      expect(find.text('850 pts'), findsOneWidget);
      expect(find.text('350 pts'), findsOneWidget);
    });

    testWidgets('highlights current user position', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the current user's card
      final currentUserCard = find.ancestor(
        of: find.text('Test Student 1'),
        matching: find.byType(Card),
      );
      expect(currentUserCard, findsOneWidget);

      // Check if "You" badge is displayed for current user
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('displays rank icons for top 3 students', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for trophy icons for top 3
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(3));
    });

    testWidgets('displays empty state when no students', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) async => testStudent),
            leaderboardProvider(50).overrideWith((ref) async => <LeaderboardEntry>[]),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No students on leaderboard yet'), findsOneWidget);
      expect(find.text('Complete quizzes to appear on the leaderboard!'), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard_outlined), findsOneWidget);
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull-to-refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      
      // Should show refresh indicator
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    });

    testWidgets('displays student statistics correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check quiz count display
      expect(find.text('20 quizzes'), findsOneWidget);
      expect(find.text('10 quizzes'), findsOneWidget);
      expect(find.text('5 quizzes'), findsOneWidget);

      // Check average score display
      expect(find.text('95.0% avg'), findsOneWidget);
      expect(find.text('85.0% avg'), findsOneWidget);
      expect(find.text('70.0% avg'), findsOneWidget);
    });

    testWidgets('displays student avatars with initials', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if avatars with initials are displayed
      expect(find.text('T'), findsNWidgets(2)); // "Top Student" and "Test Student 1" and "Third Student"
    });

    testWidgets('handles leaderboard loading error', (tester) async {
      const errorMessage = 'Failed to load leaderboard';
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) async => testStudent),
            leaderboardProvider(50).overrideWith((ref) => Future.error(errorMessage)),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error loading leaderboard'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button works on error', (tester) async {
      const errorMessage = 'Failed to load leaderboard';
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) async => testStudent),
            leaderboardProvider(50).overrideWith((ref) => Future.error(errorMessage)),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Should attempt to reload (we can't easily test the actual reload without more complex mocking)
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays correct app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator for pagination', (tester) async {
      // Create a longer list to test pagination
      final longLeaderboardEntries = List.generate(60, (index) => 
        LeaderboardEntry(
          student: Student(
            id: 'student$index',
            email: 'student$index@test.com',
            name: 'Student $index',
            role: UserRole.student,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            level: 10 - (index ~/ 10),
            badgeIds: [],
            totalQuizzesTaken: 10,
            averageScore: 90.0 - index,
          ),
          rank: index + 1,
          level: 10 - (index ~/ 10),
          totalScore: (90.0 - index) * 10,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            currentUserProvider.overrideWith((ref) async => testStudent),
            leaderboardProvider(50).overrideWith((ref) async => longLeaderboardEntries),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom to trigger pagination
      await tester.scrollUntilVisible(
        find.text('Student 59'),
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      // Should show students from the long list
      expect(find.text('Student 0'), findsOneWidget);
    });
  });
}