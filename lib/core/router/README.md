# Router Implementation

This directory contains the GoRouter-based navigation implementation for the Q-ez Quiz Application.

## Features

### 1. Role-Based Access Control
The router automatically redirects users based on their role:
- **Students** → `/student/home`
- **Teachers** → `/teacher/home`
- **Admins** → `/admin/home`

### 2. Authentication Guards
- Unauthenticated users are redirected to `/auth/login`
- Authenticated users cannot access auth routes
- Role-based route protection prevents unauthorized access

### 3. Deep Linking
Support for quiz PIN sharing via deep links:
```
/quiz/:pin
```
When a student clicks a shared quiz link, they are taken directly to the quiz entry screen.

### 4. Navigation Transitions
Custom fade transitions for smooth page changes.

### 5. Error Handling
Graceful error screen with navigation back to login.

## File Structure

```
lib/core/router/
├── app_router.dart           # Main router configuration with GoRouter
├── routes.dart               # Route path and name constants
├── route_guards.dart         # Authentication and authorization guards
├── navigation_extensions.dart # Extension methods for easy navigation
├── router.dart               # Barrel file for exports
└── README.md                 # This file
```

## Usage

### Basic Navigation

```dart
import 'package:q_ez/core/router/router.dart';

// Using extension methods
context.goToStudentHome();
context.goToQuizTaking('quiz-id-123');
context.goToLeaderboard();

// Using GoRouter directly
context.go(Routes.studentHome);
context.push(Routes.quizTakingRoute('quiz-id-123'));

// Using named routes
context.goNamed(RouteNames.studentHome);
context.goNamed(RouteNames.quizTaking, pathParameters: {'quizId': 'quiz-id-123'});
```

### Route Guards

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authGuard = AuthGuard(ref);
    final roleGuard = RoleGuard(ref);
    
    if (!authGuard.isAuthenticated()) {
      // Handle unauthenticated state
    }
    
    if (roleGuard.hasRole(UserRole.student)) {
      // Show student-specific UI
    }
    
    return Container();
  }
}
```

### Deep Linking

To share a quiz via deep link:

```dart
final pin = '123456';
final deepLink = 'https://yourapp.com/quiz/$pin';

// User clicks the link and is taken to the quiz
context.goToDeepLinkQuiz(pin);
```

## Route Structure

### Authentication Routes
- `/auth/login` - Login screen
- `/auth/signup` - Sign up screen
- `/auth/password-reset` - Password reset screen

### Student Routes
- `/student/home` - Student dashboard
- `/student/join-quiz` - Quiz PIN entry
- `/student/quiz/:quizId` - Quiz taking screen
- `/student/results/:attemptId` - Quiz results
- `/student/progress` - Progress dashboard
- `/student/leaderboard` - Global leaderboard
- `/student/badges` - Badges screen
- `/student/quiz/:quizId/top-students` - Quiz-specific top 10

### Teacher Routes
- `/teacher/home` - Teacher dashboard
- `/teacher/create-quiz` - Create new quiz
- `/teacher/quiz/:quizId/edit` - Edit quiz
- `/teacher/quiz/:quizId/analytics` - Quiz analytics
- `/teacher/student/:studentId/progress` - Student progress viewer

### Admin Routes
- `/admin/home` - Admin dashboard
- `/admin/users` - User management
- `/admin/quizzes` - Quiz management
- `/admin/audit-logs` - Audit logs

### Deep Link Routes
- `/quiz/:pin` - Direct quiz access via PIN

## Redirect Logic

The router implements the following redirect logic:

1. **Unauthenticated users**: Redirected to `/auth/login`
2. **Authenticated users on auth routes**: Redirected to role-specific home
3. **Users accessing unauthorized routes**: Redirected to role-specific home
4. **Valid navigation**: No redirect, navigation proceeds

## Adding New Routes

To add a new route:

1. Add the route path to `routes.dart`:
```dart
static const String myNewRoute = '/student/my-route';
static const String myNewRouteName = 'myNewRoute';
```

2. Add the route to `app_router.dart`:
```dart
GoRoute(
  path: Routes.myNewRoute,
  name: RouteNames.myNewRoute,
  pageBuilder: (context, state) => _buildPageWithTransition(
    context: context,
    state: state,
    child: const MyNewScreen(),
  ),
),
```

3. Add navigation extension in `navigation_extensions.dart`:
```dart
void goToMyNewRoute() => go(Routes.myNewRoute);
```

4. Update `_hasAccessToRoute()` in `app_router.dart` if needed for role-based access.

## Testing

The router can be tested by:

1. Verifying authentication redirects
2. Testing role-based access control
3. Validating deep link handling
4. Checking error handling

Example test:
```dart
testWidgets('Unauthenticated user redirected to login', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MyApp(),
    ),
  );
  
  // Verify user is on login screen
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

## Requirements Satisfied

This implementation satisfies the following requirements:

- **Requirement 1.3**: Separate authentication sessions for different user roles
- **Requirement 4.2**: Student authentication and access control
- **Requirement 10.2**: Admin authentication and role-based access

## Future Enhancements

- [ ] Add route analytics tracking
- [ ] Implement route-level loading states
- [ ] Add route transition animations per platform
- [ ] Support for nested navigation (tabs)
- [ ] Route-level middleware for logging
