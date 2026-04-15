import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

/// Extension methods for easier navigation using GoRouter
extension NavigationExtensions on BuildContext {
  // Authentication navigation
  void goToLogin() => go(Routes.login);
  void goToSignUp() => go(Routes.signUp);
  void goToPasswordReset() => go(Routes.passwordReset);

  // Student navigation
  void goToStudentHome() => go(Routes.studentHome);
  void goToJoinQuiz() => go(Routes.joinQuiz);
  void goToQuizTaking(String quizId) => go(Routes.quizTakingRoute(quizId));
  void goToQuizResults(String attemptId) => go(Routes.quizResultsRoute(attemptId));
  void goToProgressDashboard() => go(Routes.progressDashboard);
  void goToLeaderboard() => go(Routes.leaderboard);
  void goToBadges() => go(Routes.badges);
  void goToQuizTopStudents(String quizId) => go(Routes.quizTopStudentsRoute(quizId));

  // Teacher navigation
  void goToTeacherHome() => go(Routes.teacherHome);
  void goToCreateQuiz() => go(Routes.createQuiz);
  void goToEditQuiz(String quizId) => go(Routes.editQuizRoute(quizId));
  void goToQuizAnalytics(String quizId) => go(Routes.quizAnalyticsRoute(quizId));
  void goToStudentProgress(String studentId) => go(Routes.studentProgressRoute(studentId));

  // Admin navigation
  void goToAdminHome() => go(Routes.adminHome);
  void goToUserManagement() => go(Routes.userManagement);
  void goToQuizManagement() => go(Routes.quizManagement);
  void goToAuditLogs() => go(Routes.auditLogs);

  // Settings navigation
  void goToSettings() => go(Routes.settings);
  void pushSettings() => push(Routes.settings);

  // Deep linking navigation
  void goToDeepLinkQuiz(String pin) => go(Routes.deepLinkQuizRoute(pin));

  // Push navigation (keeps current route in stack)
  void pushQuizTaking(String quizId) => push(Routes.quizTakingRoute(quizId));
  void pushQuizResults(String attemptId) => push(Routes.quizResultsRoute(attemptId));
  void pushEditQuiz(String quizId) => push(Routes.editQuizRoute(quizId));
  void pushQuizAnalytics(String quizId) => push(Routes.quizAnalyticsRoute(quizId));
  void pushStudentProgress(String studentId) => push(Routes.studentProgressRoute(studentId));

  // Named navigation
  void goToLoginNamed() => goNamed(RouteNames.login);
  void goToSignUpNamed() => goNamed(RouteNames.signUp);
  void goToPasswordResetNamed() => goNamed(RouteNames.passwordReset);
  void goToStudentHomeNamed() => goNamed(RouteNames.studentHome);
  void goToTeacherHomeNamed() => goNamed(RouteNames.teacherHome);
  void goToAdminHomeNamed() => goNamed(RouteNames.adminHome);

  // Navigation with parameters using named routes
  void goToQuizTakingNamed(String quizId) => goNamed(
        RouteNames.quizTaking,
        pathParameters: {'quizId': quizId},
      );

  void goToQuizResultsNamed(String attemptId) => goNamed(
        RouteNames.quizResults,
        pathParameters: {'attemptId': attemptId},
      );

  void goToEditQuizNamed(String quizId) => goNamed(
        RouteNames.editQuiz,
        pathParameters: {'quizId': quizId},
      );

  void goToQuizAnalyticsNamed(String quizId) => goNamed(
        RouteNames.quizAnalytics,
        pathParameters: {'quizId': quizId},
      );

  void goToStudentProgressNamed(String studentId) => goNamed(
        RouteNames.studentProgress,
        pathParameters: {'studentId': studentId},
      );

  void goToQuizTopStudentsNamed(String quizId) => goNamed(
        RouteNames.quizTopStudents,
        pathParameters: {'quizId': quizId},
      );

  void goToDeepLinkQuizNamed(String pin) => goNamed(
        RouteNames.deepLinkQuiz,
        pathParameters: {'pin': pin},
      );
}
