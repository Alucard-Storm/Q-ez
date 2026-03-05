import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';
import '../../presentation/screens/auth/password_reset_screen.dart';
import '../../presentation/screens/student/student_home_screen.dart';
import '../../presentation/screens/student/join_quiz_screen.dart';
import '../../presentation/screens/student/quiz_taking_screen.dart';
import '../../presentation/screens/student/quiz_results_screen.dart';
import '../../presentation/screens/student/progress_dashboard_screen.dart';
import '../../presentation/screens/student/leaderboard_screen.dart';
import '../../presentation/screens/student/badges_screen.dart';
import '../../presentation/screens/student/quiz_top_students_screen.dart';
import 'routes.dart';

/// Provider for GoRouter instance with authentication and role-based access control
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: true,
    
    // Redirect logic for authentication and authorization
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final user = authState.value;
      final currentPath = state.matchedLocation;

      // Allow access to auth routes when not authenticated
      if (!isAuthenticated) {
        if (currentPath.startsWith('/auth')) {
          return null; // Allow access to auth routes
        }
        return Routes.login; // Redirect to login
      }

      // Redirect from auth routes to appropriate home when authenticated
      if (currentPath.startsWith('/auth')) {
        return _getHomeRouteForRole(user!.role);
      }

      // Check role-based access for protected routes
      if (!_hasAccessToRoute(currentPath, user!.role)) {
        return _getHomeRouteForRole(user.role);
      }

      return null; // Allow navigation
    },

    // Refresh router when auth state changes
    refreshListenable: GoRouterRefreshStream(authState),

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),

    routes: [
      // Authentication routes
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signUp,
        name: RouteNames.signUp,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: Routes.passwordReset,
        name: RouteNames.passwordReset,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const PasswordResetScreen(),
        ),
      ),

      // Student routes
      GoRoute(
        path: Routes.studentHome,
        name: RouteNames.studentHome,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const StudentHomeScreen(),
        ),
      ),
      GoRoute(
        path: Routes.joinQuiz,
        name: RouteNames.joinQuiz,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const JoinQuizScreen(),
        ),
      ),
      GoRoute(
        path: Routes.quizTaking,
        name: RouteNames.quizTaking,
        pageBuilder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: QuizTakingScreen(quizId: quizId),
          );
        },
      ),
      GoRoute(
        path: Routes.quizResults,
        name: RouteNames.quizResults,
        pageBuilder: (context, state) {
          final attemptId = state.pathParameters['attemptId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: QuizResultsScreen(attemptId: attemptId),
          );
        },
      ),
      GoRoute(
        path: Routes.progressDashboard,
        name: RouteNames.progressDashboard,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProgressDashboardScreen(),
        ),
      ),
      GoRoute(
        path: Routes.leaderboard,
        name: RouteNames.leaderboard,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LeaderboardScreen(),
        ),
      ),
      GoRoute(
        path: Routes.badges,
        name: RouteNames.badges,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const BadgesScreen(),
        ),
      ),
      GoRoute(
        path: Routes.quizTopStudents,
        name: RouteNames.quizTopStudents,
        pageBuilder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: QuizTopStudentsScreen(quizId: quizId),
          );
        },
      ),

      // Teacher routes
      GoRoute(
        path: Routes.teacherHome,
        name: RouteNames.teacherHome,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with TeacherHomeScreen
        ),
      ),
      GoRoute(
        path: Routes.createQuiz,
        name: RouteNames.createQuiz,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with CreateQuizScreen
        ),
      ),
      GoRoute(
        path: Routes.editQuiz,
        name: RouteNames.editQuiz,
        pageBuilder: (context, state) {
          // final quizId = state.pathParameters['quizId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const Placeholder(), // TODO: Replace with EditQuizScreen(quizId: quizId)
          );
        },
      ),
      GoRoute(
        path: Routes.quizAnalytics,
        name: RouteNames.quizAnalytics,
        pageBuilder: (context, state) {
          // final quizId = state.pathParameters['quizId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const Placeholder(), // TODO: Replace with QuizAnalyticsScreen(quizId: quizId)
          );
        },
      ),
      GoRoute(
        path: Routes.studentProgress,
        name: RouteNames.studentProgress,
        pageBuilder: (context, state) {
          // final studentId = state.pathParameters['studentId']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const Placeholder(), // TODO: Replace with StudentProgressScreen(studentId: studentId)
          );
        },
      ),

      // Admin routes
      GoRoute(
        path: Routes.adminHome,
        name: RouteNames.adminHome,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with AdminHomeScreen
        ),
      ),
      GoRoute(
        path: Routes.userManagement,
        name: RouteNames.userManagement,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with UserManagementScreen
        ),
      ),
      GoRoute(
        path: Routes.quizManagement,
        name: RouteNames.quizManagement,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with QuizManagementScreen
        ),
      ),
      GoRoute(
        path: Routes.auditLogs,
        name: RouteNames.auditLogs,
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Placeholder(), // TODO: Replace with AuditLogsScreen
        ),
      ),

      // Deep linking route for quiz PIN sharing
      GoRoute(
        path: Routes.deepLinkQuiz,
        name: RouteNames.deepLinkQuiz,
        pageBuilder: (context, state) {
          // final pin = state.pathParameters['pin']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: const Placeholder(), // TODO: Replace with DeepLinkQuizScreen(pin: pin)
          );
        },
      ),
    ],
  );
});

/// Helper function to get home route based on user role
String _getHomeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.student:
      return Routes.studentHome;
    case UserRole.teacher:
      return Routes.teacherHome;
    case UserRole.admin:
      return Routes.adminHome;
  }
}

/// Helper function to check if user has access to a route based on role
bool _hasAccessToRoute(String path, UserRole role) {
  // Student routes
  if (path.startsWith('/student')) {
    return role == UserRole.student;
  }
  
  // Teacher routes
  if (path.startsWith('/teacher')) {
    return role == UserRole.teacher;
  }
  
  // Admin routes
  if (path.startsWith('/admin')) {
    return role == UserRole.admin;
  }
  
  // Deep link routes accessible to students
  if (path.startsWith('/quiz/')) {
    return role == UserRole.student;
  }
  
  return false;
}

/// Helper function to build page with custom transition
Page<dynamic> _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade transition
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

/// Error screen for navigation errors
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AsyncValue<User?> authState) {
    authState.whenData((user) {
      notifyListeners();
    });
  }
}
