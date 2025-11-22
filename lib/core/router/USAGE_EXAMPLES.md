# Router Usage Examples

This document provides practical examples of using the GoRouter implementation in the Q-ez Quiz Application.

## Basic Navigation

### Using Extension Methods (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:q_ez/core/router/router.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to student home
        context.goToStudentHome();
        
        // Navigate to a quiz
        context.goToQuizTaking('quiz-123');
        
        // Navigate to leaderboard
        context.goToLeaderboard();
      },
      child: Text('Navigate'),
    );
  }
}
```

### Using GoRouter Directly

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:q_ez/core/router/router.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Replace current route
        context.go(Routes.studentHome);
        
        // Push new route (keeps current in stack)
        context.push(Routes.quizTakingRoute('quiz-123'));
        
        // Pop current route
        context.pop();
      },
      child: Text('Navigate'),
    );
  }
}
```

## Authentication Flow

### Login and Redirect

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';
import 'package:q_ez/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () async {
          final authRepo = ref.read(authRepositoryProvider);
          
          try {
            // Sign in user
            final user = await authRepo.signIn(
              'student@example.com',
              'password',
              UserRole.student,
            );
            
            // Router will automatically redirect to appropriate home
            // based on user role (handled by redirect logic)
          } catch (e) {
            // Handle error
          }
        },
        child: Text('Login'),
      ),
    );
  }
}
```

### Logout

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';
import 'package:q_ez/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final authRepo = ref.read(authRepositoryProvider);
        
        await authRepo.signOut();
        
        // Router will automatically redirect to login
        // (handled by redirect logic)
      },
      child: Text('Logout'),
    );
  }
}
```

## Role-Based Navigation

### Checking User Role Before Navigation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';
import 'package:q_ez/presentation/providers/auth_providers.dart';

class NavigationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return Text('Not logged in');
        }
        
        // Navigate based on role
        return ElevatedButton(
          onPressed: () {
            switch (user.role) {
              case UserRole.student:
                context.goToStudentHome();
                break;
              case UserRole.teacher:
                context.goToTeacherHome();
                break;
              case UserRole.admin:
                context.goToAdminHome();
                break;
            }
          },
          child: Text('Go to Home'),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Using Route Guards

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';

class ProtectedWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleGuard = RoleGuard(ref);
    
    // Check if user is a student
    if (!roleGuard.hasRole(UserRole.student)) {
      return Text('Access denied');
    }
    
    // Check if user is teacher or admin
    if (roleGuard.hasAnyRole([UserRole.teacher, UserRole.admin])) {
      return Text('Admin or Teacher content');
    }
    
    return Text('Student content');
  }
}
```

## Deep Linking

### Sharing Quiz via Deep Link

```dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class QuizShareButton extends StatelessWidget {
  final String quizPin;
  
  const QuizShareButton({required this.quizPin});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Create deep link URL
        final deepLink = 'https://qez.app/quiz/$quizPin';
        
        // Share the link
        Share.share(
          'Join my quiz with PIN: $quizPin\n$deepLink',
          subject: 'Quiz Invitation',
        );
      },
      child: Text('Share Quiz'),
    );
  }
}
```

### Handling Deep Link

```dart
// The router automatically handles deep links
// When a user clicks /quiz/123456, they are taken to the quiz screen
// The router extracts the PIN and passes it to the screen

// In your quiz screen:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeepLinkQuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get PIN from route parameters
    final pin = GoRouterState.of(context).pathParameters['pin'];
    
    return Scaffold(
      body: Center(
        child: Text('Quiz PIN: $pin'),
      ),
    );
  }
}
```

## Navigation with Parameters

### Passing Simple Parameters

```dart
import 'package:flutter/material.dart';
import 'package:q_ez/core/router/router.dart';

class QuizListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizId = 'quiz-123';
    
    return ElevatedButton(
      onPressed: () {
        // Navigate to quiz taking screen with quiz ID
        context.goToQuizTaking(quizId);
        
        // Or using named route
        context.goToQuizTakingNamed(quizId);
      },
      child: Text('Start Quiz'),
    );
  }
}
```

### Passing Complex Data via Extra

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:q_ez/core/router/router.dart';

class QuizListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizData = {
      'id': 'quiz-123',
      'title': 'Math Quiz',
      'duration': 30,
    };
    
    return ElevatedButton(
      onPressed: () {
        // Pass extra data
        context.push(
          Routes.quizTakingRoute('quiz-123'),
          extra: quizData,
        );
      },
      child: Text('Start Quiz'),
    );
  }
}

// In the destination screen:
class QuizTakingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve extra data
    final state = GoRouterState.of(context);
    final quizData = state.extra as Map<String, dynamic>?;
    
    return Scaffold(
      body: Text('Quiz: ${quizData?['title']}'),
    );
  }
}
```

## Navigation Stack Management

### Push vs Go

```dart
import 'package:flutter/material.dart';
import 'package:q_ez/core/router/router.dart';

class NavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Replace current route (no back button)
        ElevatedButton(
          onPressed: () => context.goToStudentHome(),
          child: Text('Go (Replace)'),
        ),
        
        // Push new route (keeps current in stack)
        ElevatedButton(
          onPressed: () => context.pushQuizTaking('quiz-123'),
          child: Text('Push (Keep in Stack)'),
        ),
        
        // Pop current route
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text('Go Back'),
        ),
      ],
    );
  }
}
```

### Replacing Entire Stack

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:q_ez/core/router/router.dart';

class QuizCompletionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Clear entire navigation stack and go to home
        // This prevents user from going back to quiz
        context.go(Routes.studentHome);
      },
      child: Text('Return to Home'),
    );
  }
}
```

## Error Handling

### Handling Navigation Errors

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:q_ez/core/router/router.dart';

class SafeNavigationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        try {
          context.goToQuizTaking('quiz-123');
        } catch (e) {
          // Handle navigation error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigation failed: $e')),
          );
        }
      },
      child: Text('Navigate Safely'),
    );
  }
}
```

## Testing Navigation

### Testing Route Redirects

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/main.dart';

void main() {
  testWidgets('Unauthenticated user redirected to login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Verify user is on login screen
    expect(find.text('Login'), findsOneWidget);
  });
}
```

### Testing Role-Based Access

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_ez/core/router/router.dart';
import 'package:q_ez/domain/entities/user.dart';

void main() {
  test('Student cannot access teacher routes', () {
    final container = ProviderContainer();
    final roleGuard = RoleGuard(container);
    
    // Mock student user
    // ... setup mock
    
    expect(roleGuard.hasRole(UserRole.teacher), false);
    expect(roleGuard.hasRole(UserRole.student), true);
  });
}
```

## Best Practices

### 1. Use Extension Methods

```dart
// ✅ Good - Clean and readable
context.goToStudentHome();

// ❌ Avoid - Verbose
context.go(Routes.studentHome);
```

### 2. Handle Async Navigation

```dart
// ✅ Good - Handle async operations before navigation
Future<void> submitQuiz() async {
  try {
    await quizRepository.submitQuiz(quizId);
    if (mounted) {
      context.goToQuizResults(attemptId);
    }
  } catch (e) {
    // Handle error
  }
}
```

### 3. Use Named Routes for Complex Navigation

```dart
// ✅ Good - Clear parameter passing
context.goToQuizTakingNamed(quizId);

// ❌ Avoid - Manual string interpolation
context.go('/student/quiz/$quizId');
```

### 4. Check Authentication State

```dart
// ✅ Good - Check auth state before navigation
final authState = ref.watch(authStateProvider);
if (authState.value != null) {
  context.goToStudentHome();
}

// ❌ Avoid - Navigate without checking
context.goToStudentHome(); // May fail if not authenticated
```
