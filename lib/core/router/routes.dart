/// Route paths for the application
class Routes {
  // Authentication routes
  static const String login = '/auth/login';
  static const String signUp = '/auth/signup';
  static const String passwordReset = '/auth/password-reset';

  // Student routes
  static const String studentHome = '/student/home';
  static const String joinQuiz = '/student/join-quiz';
  static const String quizTaking = '/student/quiz/:quizId';
  static const String quizResults = '/student/results/:attemptId';
  static const String progressDashboard = '/student/progress';
  static const String leaderboard = '/student/leaderboard';
  static const String badges = '/student/badges';
  static const String quizTopStudents = '/student/quiz/:quizId/top-students';

  // Teacher routes
  static const String teacherHome = '/teacher/home';
  static const String createQuiz = '/teacher/create-quiz';
  static const String editQuiz = '/teacher/quiz/:quizId/edit';
  static const String quizAnalytics = '/teacher/quiz/:quizId/analytics';
  static const String studentProgress = '/teacher/student/:studentId/progress';

  // Admin routes
  static const String adminHome = '/admin/home';
  static const String userManagement = '/admin/users';
  static const String quizManagement = '/admin/quizzes';
  static const String auditLogs = '/admin/audit-logs';

  // Settings route (accessible to all authenticated users)
  static const String settings = '/settings';

  // Deep linking routes
  static const String deepLinkQuiz = '/quiz/:pin';

  // Helper methods to build routes with parameters
  static String quizTakingRoute(String quizId) => '/student/quiz/$quizId';
  static String quizResultsRoute(String attemptId) => '/student/results/$attemptId';
  static String quizTopStudentsRoute(String quizId) => '/student/quiz/$quizId/top-students';
  static String editQuizRoute(String quizId) => '/teacher/quiz/$quizId/edit';
  static String quizAnalyticsRoute(String quizId) => '/teacher/quiz/$quizId/analytics';
  static String studentProgressRoute(String studentId) => '/teacher/student/$studentId/progress';
  static String deepLinkQuizRoute(String pin) => '/quiz/$pin';
}

/// Route names for named navigation
class RouteNames {
  // Authentication routes
  static const String login = 'login';
  static const String signUp = 'signUp';
  static const String passwordReset = 'passwordReset';

  // Student routes
  static const String studentHome = 'studentHome';
  static const String joinQuiz = 'joinQuiz';
  static const String quizTaking = 'quizTaking';
  static const String quizResults = 'quizResults';
  static const String progressDashboard = 'progressDashboard';
  static const String leaderboard = 'leaderboard';
  static const String badges = 'badges';
  static const String quizTopStudents = 'quizTopStudents';

  // Teacher routes
  static const String teacherHome = 'teacherHome';
  static const String createQuiz = 'createQuiz';
  static const String editQuiz = 'editQuiz';
  static const String quizAnalytics = 'quizAnalytics';
  static const String studentProgress = 'studentProgress';

  // Admin routes
  static const String adminHome = 'adminHome';
  static const String userManagement = 'userManagement';
  static const String quizManagement = 'quizManagement';
  static const String auditLogs = 'auditLogs';

  // Settings route
  static const String settings = 'settings';

  // Deep linking routes
  static const String deepLinkQuiz = 'deepLinkQuiz';
}
