/// Firestore collection and field name constants
/// This ensures consistency across the application and prevents typos
class FirestoreConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String quizAttemptsCollection = 'quiz_attempts';
  static const String badgesCollection = 'badges';
  static const String leaderboardCollection = 'leaderboard';
  static const String quizLeaderboardsCollection = 'quiz_leaderboards';
  static const String auditLogsCollection = 'audit_logs';

  // User fields
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userRole = 'role';
  static const String userCreatedAt = 'createdAt';
  static const String userLastLoginAt = 'lastLoginAt';

  // Student-specific fields
  static const String studentLevel = 'level';
  static const String studentBadgeIds = 'badgeIds';
  static const String studentTotalQuizzesTaken = 'totalQuizzesTaken';
  static const String studentAverageScore = 'averageScore';

  // Teacher-specific fields
  static const String teacherCreatedQuizIds = 'createdQuizIds';

  // Admin-specific fields
  static const String adminAuditLogIds = 'auditLogIds';

  // User role values
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';

  // Quiz fields
  static const String quizId = 'id';
  static const String quizTitle = 'title';
  static const String quizDescription = 'description';
  static const String quizTeacherId = 'teacherId';
  static const String quizPin = 'pin';
  static const String quizTimeLimitMinutes = 'timeLimitMinutes';
  static const String quizCreatedAt = 'createdAt';
  static const String quizIsActive = 'isActive';
  static const String quizQuestions = 'questions';

  // Question fields
  static const String questionId = 'id';
  static const String questionText = 'text';
  static const String questionOptions = 'options';
  static const String questionCorrectOptionIndex = 'correctOptionIndex';

  // Quiz attempt fields
  static const String attemptId = 'id';
  static const String attemptStudentId = 'studentId';
  static const String attemptQuizId = 'quizId';
  static const String attemptAnswers = 'answers';
  static const String attemptScore = 'score';
  static const String attemptTotalQuestions = 'totalQuestions';
  static const String attemptStartedAt = 'startedAt';
  static const String attemptCompletedAt = 'completedAt';
  static const String attemptSecurityViolations = 'securityViolations';
  static const String attemptViolations = 'violations';
  static const String attemptIsFlagged = 'isFlagged';

  // Violation fields
  static const String violationType = 'type';
  static const String violationTimestamp = 'timestamp';

  // Violation type values
  static const String violationTypeTabSwitch = 'tabSwitch';
  static const String violationTypeAppSwitch = 'appSwitch';
  static const String violationTypeCopyAttempt = 'copyAttempt';

  // Badge fields
  static const String badgeId = 'id';
  static const String badgeName = 'name';
  static const String badgeDescription = 'description';
  static const String badgeIconAsset = 'iconAsset';
  static const String badgeType = 'type';
  static const String badgeRequirement = 'requirement';

  // Badge type values
  static const String badgeTypeQuizzesCompleted = 'quizzesCompleted';
  static const String badgeTypePerfectScore = 'perfectScore';
  static const String badgeTypeLevelReached = 'levelReached';

  // Leaderboard fields
  static const String leaderboardRankings = 'rankings';
  static const String leaderboardLastUpdated = 'lastUpdated';

  // Ranking fields
  static const String rankingStudentId = 'studentId';
  static const String rankingLevel = 'level';
  static const String rankingTotalScore = 'totalScore';
  static const String rankingScore = 'score';
  static const String rankingCompletedAt = 'completedAt';
  static const String rankingRank = 'rank';

  // Audit log fields
  static const String auditLogId = 'id';
  static const String auditLogAdminId = 'adminId';
  static const String auditLogAction = 'action';
  static const String auditLogTargetType = 'targetType';
  static const String auditLogTargetId = 'targetId';
  static const String auditLogDetails = 'details';
  static const String auditLogTimestamp = 'timestamp';

  // Special document IDs
  static const String globalLeaderboardDocId = 'global';

  // Query limits
  static const int leaderboardLimit = 100;
  static const int topStudentsLimit = 10;
  static const int recentQuizzesLimit = 10;

  // Security
  static const int maxSecurityViolations = 3;
  static const int passingScorePercentage = 60;
}
