# Riverpod Providers Documentation

This directory contains all Riverpod providers for state management in the Q-ez Quiz Application.

## Provider Files

### auth_providers.dart
Authentication-related providers:
- `userRepositoryProvider` - UserRepository dependency injection
- `authRepositoryProvider` - AuthRepository dependency injection
- `authStateProvider` - StreamProvider for reactive auth state changes
- `currentUserProvider` - FutureProvider for current logged-in user

### quiz_providers.dart
Quiz and quiz attempt providers:
- `quizRepositoryProvider` - QuizRepository dependency injection
- `attemptRepositoryProvider` - QuizAttemptRepository dependency injection
- `activeAttemptProvider` - StateNotifier for managing active quiz attempts
- `timerProvider` - StateNotifier family for quiz countdown timers
- `securityMonitorProvider` - Security monitor for anti-cheating system
- `quizByPinProvider` - FutureProvider family for getting quiz by PIN
- `quizByIdProvider` - FutureProvider family for getting quiz by ID
- `quizzesStreamProvider` - StreamProvider for real-time quiz updates
- `quizzesByTeacherProvider` - FutureProvider family for teacher's quizzes

### student_providers.dart
Student feature providers:
- `badgeRepositoryProvider` - BadgeRepository dependency injection
- `progressDashboardProvider` - FutureProvider family for student progress dashboard
- `leaderboardProvider` - FutureProvider family for global leaderboard
- `badgesProvider` - FutureProvider for all available badges
- `studentBadgesProvider` - FutureProvider family for student's earned badges
- `availableBadgesProvider` - FutureProvider family for badges student can earn
- `quizTopStudentsProvider` - FutureProvider family for top 10 students per quiz
- `studentAttemptsProvider` - FutureProvider family for student's quiz attempts

### admin_providers.dart
Admin and teacher management providers:
- `manageUsersUseCaseProvider` - ManageUsersUseCase dependency injection
- `manageQuizzesUseCaseProvider` - ManageQuizzesUseCase dependency injection
- `viewAuditLogsUseCaseProvider` - ViewAuditLogsUseCase dependency injection
- `allUsersProvider` - FutureProvider for all users (admin only)
- `allStudentsProvider` - FutureProvider for all students (admin only)
- `allTeachersProvider` - FutureProvider for all teachers (admin only)
- `userByIdProvider` - FutureProvider family for specific user (admin only)
- `allQuizzesProvider` - FutureProvider for all quizzes (admin only)
- `quizzesByTeacherAdminProvider` - FutureProvider family for teacher's quizzes (admin only)
- `auditLogsProvider` - FutureProvider for all security violations (admin only)
- `studentViolationsProvider` - FutureProvider family for student violations (admin only)
- `quizViolationsProvider` - FutureProvider family for quiz violations (admin only)

## Usage Examples

### Authentication
```dart
// Watch auth state changes
final authState = ref.watch(authStateProvider);

// Get current user
final currentUser = ref.watch(currentUserProvider);

// Sign in
final authRepo = ref.read(authRepositoryProvider);
await authRepo.signIn(email, password, UserRole.student);
```

### Quiz Taking
```dart
// Start a quiz attempt
final attemptNotifier = ref.read(activeAttemptProvider.notifier);
await attemptNotifier.startAttempt(studentId, quizId);

// Submit an answer
await attemptNotifier.submitAnswer(questionId, selectedOption);

// Start timer
final timerNotifier = ref.read(timerProvider(30).notifier);
timerNotifier.start();

// Monitor security
final securityMonitor = ref.read(securityMonitorProvider);
securityMonitor.startMonitoring(attemptId);
```

### Student Features
```dart
// Get progress dashboard
final progress = ref.watch(progressDashboardProvider(studentId));

// Get leaderboard
final leaderboard = ref.watch(leaderboardProvider(100));

// Get badges
final badges = ref.watch(badgesProvider);
final earnedBadges = ref.watch(studentBadgesProvider(studentId));

// Get top students for quiz
final topStudents = ref.watch(quizTopStudentsProvider(quizId));
```

### Admin Features
```dart
// Get all users
final users = ref.watch(allUsersProvider);

// Get all quizzes
final quizzes = ref.watch(allQuizzesProvider);

// Get audit logs
final auditLogs = ref.watch(auditLogsProvider);

// Manage users
final manageUsers = ref.read(manageUsersUseCaseProvider);
await manageUsers.deleteUser(userId);

// Manage quizzes
final manageQuizzes = ref.read(manageQuizzesUseCaseProvider);
await manageQuizzes.setQuizActive(quizId, true);
```

## Provider Types

### Provider
Basic provider for dependency injection. Does not rebuild when dependencies change.

### FutureProvider
Provider for async operations. Automatically handles loading, data, and error states.

### StreamProvider
Provider for streams. Automatically subscribes and unsubscribes.

### StateNotifierProvider
Provider for mutable state with StateNotifier. Used for complex state management.

### Family Providers
Providers that accept parameters. Create separate provider instances for each parameter value.

## Best Practices

1. **Use ref.watch** in build methods to rebuild when provider changes
2. **Use ref.read** for one-time reads or in event handlers
3. **Use ref.listen** to react to provider changes without rebuilding
4. **Dispose resources** in StateNotifier.dispose() method
5. **Handle errors** using AsyncValue pattern for FutureProvider/StreamProvider
6. **Keep providers focused** - each provider should have a single responsibility
7. **Use family providers** for parameterized data fetching
8. **Avoid circular dependencies** between providers

## State Management Flow

```
UI Widget
    ↓ ref.watch/read
Provider
    ↓ uses
Repository/UseCase
    ↓ calls
Data Source (Firebase/Hive)
```

## Testing

Providers can be easily tested using ProviderContainer:

```dart
test('authStateProvider emits user when authenticated', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );
  
  final authState = container.read(authStateProvider);
  // Assert expectations
});
```
