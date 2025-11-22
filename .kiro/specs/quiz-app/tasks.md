# Implementation Plan

- [x] 1. Set up Flutter project structure and dependencies









  - Initialize Flutter project with proper SDK constraints (Dart 3.0+, Flutter 3.10+)
  - Configure pubspec.yaml with all required dependencies (Riverpod, Firebase, Hive, GoRouter, etc.)
  - Set up platform-specific configurations (Android SDK 32, iOS 16.0)
  - Create folder structure following clean architecture (data, domain, presentation layers)
  - _Requirements: 17.1, 17.2_

- [x] 2. Implement core domain entities and models






  - [x] 2.1 Create User entity hierarchy with Student, Teacher, and Admin classes

    - Define abstract User class with common properties
    - Implement Student class with level, badges, and statistics
    - Implement Teacher and Admin classes with role-specific properties
    - Add Freezed annotations for immutability and code generation
    - _Requirements: 1.1, 1.3, 4.1, 4.3, 10.1_

  - [x] 2.2 Create Quiz and Question entities

    - Define Quiz class with title, description, PIN, time limit, and questions
    - Define Question class with text, four options, and correct answer index
    - Add validation logic for quiz data integrity
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1_

  - [x] 2.3 Create QuizAttempt and SecurityViolation entities

    - Define QuizAttempt class with answers, score, timestamps, and violations
    - Define SecurityViolation class with type and timestamp
    - Add enums for SecurityViolationType
    - _Requirements: 5.4, 5.5, 15.3, 15.4, 15.5_

  - [x] 2.4 Create Badge entity and achievement system models

    - Define Badge class with name, description, icon, type, and requirements
    - Add BadgeType enum for different achievement categories
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [x] 3. Set up Firebase configuration and initialization






  - [x] 3.1 Configure Firebase for Android, iOS, and Web platforms

    - Add Firebase configuration files (google-services.json, GoogleService-Info.plist, firebase-config.js)
    - Initialize Firebase in main.dart with platform detection
    - Set up Firebase Crashlytics for error reporting
    - _Requirements: 17.1, 17.5_

  - [x] 3.2 Define Firestore collection structure and security rules

    - Create Firestore collections schema (users, quizzes, quiz_attempts, badges, leaderboard)
    - Write Firestore security rules for role-based access control
    - Create indexes for optimized queries (studentId, quizId, score, level)
    - _Requirements: 1.3, 10.3, 11.1_

- [x] 4. Implement repository interfaces in domain layer





  - Define AuthRepository interface with sign in, sign up, sign out, and auth state methods
  - Define QuizRepository interface with CRUD operations and PIN-based queries
  - Define QuizAttemptRepository interface with attempt lifecycle methods
  - Define UserRepository interface with student, teacher, and admin operations
  - Define BadgeRepository interface with badge retrieval and awarding methods
  - _Requirements: 1.1, 1.2, 2.1, 4.1, 4.2, 5.1, 10.1, 11.1, 12.1_

- [x] 5. Implement Firebase repository implementations in data layer





  - [x] 5.1 Implement FirebaseAuthRepository


    - Implement email/password authentication with Firebase Auth
    - Add role-based authentication using custom claims
    - Implement auth state stream for reactive authentication
    - Add password reset functionality
    - _Requirements: 1.1, 1.2, 1.3, 4.1, 4.2, 10.1, 10.2_
  - [x] 5.2 Implement FirebaseQuizRepository


    - Implement quiz creation with automatic PIN generation when blank
    - Add PIN uniqueness validation logic
    - Implement quiz retrieval by PIN and by ID
    - Add CRUD operations for quizzes with teacher and admin permissions
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 12.1, 12.2, 12.3_
  - [x] 5.3 Implement FirebaseQuizAttemptRepository


    - Implement quiz attempt creation and initialization
    - Add answer submission and recording logic
    - Implement quiz completion with score calculation
    - Add security violation recording and tracking
    - Implement auto-submit logic when violations reach threshold
    - _Requirements: 5.1, 5.2, 5.4, 5.5, 5.6, 6.1, 6.2, 15.5, 15.6, 15.7_
  - [x] 5.4 Implement FirebaseUserRepository


    - Implement student profile retrieval and updates
    - Add level progression logic with passing threshold check
    - Implement leaderboard generation with ranking algorithm
    - Add top 10 students per quiz with score and time-based ranking
    - Implement admin user management operations
    - _Requirements: 4.3, 4.4, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 11.1, 11.2, 11.3, 11.4, 11.5_
  - [x] 5.5 Implement FirebaseBadgeRepository


    - Implement badge retrieval for all available badges
    - Add student badge fetching logic
    - Implement badge awarding logic with criteria checking
    - Add automatic badge checking after quiz completion
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

- [-] 6. Set up local storage with Hive for offline caching


  - [-] 6.1 Configure Hive and create type adapters

    - Initialize Hive with Flutter integration
    - Create Hive type adapters for User, Quiz, and security settings
    - Set up encrypted Hive boxes for sensitive data
    - _Requirements: 17.1_
  - [ ] 6.2 Implement local cache repository
    - Create cache repository for storing user session data
    - Implement quiz caching for offline access
    - Add cache invalidation and sync logic
    - _Requirements: 17.1_

- [ ] 7. Implement use cases for business logic
  - [ ] 7.1 Implement authentication use cases
    - Create SignInUseCase with role validation
    - Create SignUpUseCase with initial profile setup
    - Create SignOutUseCase with cache clearing
    - _Requirements: 1.1, 1.2, 4.1, 4.2, 10.1, 10.2_
  - [ ] 7.2 Implement quiz management use cases
    - Create CreateQuizUseCase with PIN generation logic
    - Create UpdateQuizUseCase with permission validation
    - Create DeleteQuizUseCase with cascade deletion
    - Create GetQuizByPinUseCase for student quiz access
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 12.2, 12.3, 12.4_
  - [ ] 7.3 Implement quiz participation use cases
    - Create JoinQuizUseCase with PIN validation
    - Create SubmitAnswerUseCase with answer recording
    - Create CompleteQuizUseCase with score calculation, level update, and badge awarding
    - _Requirements: 5.1, 5.2, 5.4, 5.5, 5.6, 7.1, 7.2, 7.3, 7.4, 7.5, 13.4_
  - [ ] 7.4 Implement progress and leaderboard use cases
    - Create GetProgressDashboardUseCase with statistics calculation
    - Create GetLeaderboardUseCase with ranking logic
    - Create GetQuizTopStudentsUseCase for top 10 retrieval
    - _Requirements: 6.2, 6.3, 6.4, 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 9.4, 9.5, 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_
  - [ ] 7.5 Implement admin management use cases
    - Create ManageUsersUseCase with CRUD operations
    - Create ManageQuizzesUseCase with admin override permissions
    - Create ViewAuditLogsUseCase for security monitoring
    - _Requirements: 10.3, 10.4, 11.1, 11.2, 11.3, 11.4, 11.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 8. Implement security monitoring system
  - [ ] 8.1 Create web security monitor for browser-based anti-cheating
    - Implement right-click disable functionality using dart:html
    - Add text selection and copy prevention
    - Implement tab visibility change detection
    - Add keyboard shortcut blocking (Ctrl+C, Ctrl+X, Ctrl+A)
    - _Requirements: 15.1, 15.2, 15.3, 15.8_
  - [ ] 8.2 Create mobile security monitor for app-based anti-cheating
    - Implement app lifecycle observer for app switch detection
    - Add long-press gesture blocking
    - Implement secure screen wrapper widget
    - _Requirements: 15.4, 15.8_
  - [ ] 8.3 Implement violation recording and auto-submit logic
    - Create SecurityMonitor service with violation counter
    - Add violation recording to QuizAttempt
    - Implement auto-submit when violation threshold (3) is reached
    - Add flagging logic for suspicious attempts
    - _Requirements: 15.5, 15.6, 15.7, 15.8_

- [ ] 9. Set up state management with Riverpod
  - [ ] 9.1 Create authentication providers
    - Define authRepositoryProvider for dependency injection
    - Create authStateProvider as StreamProvider for reactive auth state
    - Add currentUserProvider for accessing logged-in user data
    - _Requirements: 1.2, 1.3, 4.2, 10.2_
  - [ ] 9.2 Create quiz and attempt providers
    - Define quizRepositoryProvider and attemptRepositoryProvider
    - Create activeAttemptProvider as StateNotifier for quiz taking state
    - Add timerProvider as StateNotifier for countdown timer
    - Create securityMonitorProvider for anti-cheating system
    - _Requirements: 5.2, 5.3, 5.4, 15.3, 15.4_
  - [ ] 9.3 Create student feature providers
    - Define progressDashboardProvider for student statistics
    - Create leaderboardProvider for global rankings
    - Add badgesProvider for achievement system
    - Create quizTopStudentsProvider for per-quiz rankings
    - _Requirements: 8.1, 8.4, 9.1, 9.4, 13.6, 14.1_
  - [ ] 9.4 Create admin and teacher providers
    - Define allUsersProvider for user management
    - Create allQuizzesProvider for quiz management
    - Add auditLogsProvider for security logs
    - _Requirements: 11.1, 12.1, 16.1_

- [ ] 10. Implement navigation with GoRouter
  - Define route structure with role-based access control
  - Create route guards for authentication and authorization
  - Implement deep linking for quiz PIN sharing
  - Add navigation transitions and error handling
  - _Requirements: 1.3, 4.2, 10.2_

- [ ] 11. Build authentication UI screens
  - [ ] 11.1 Create login screen with role selection
    - Build adaptive login form with email and password fields
    - Add role selector (Student, Teacher, Admin)
    - Implement form validation and error display
    - Add navigation to sign up and password reset screens
    - _Requirements: 1.1, 1.2, 4.1, 4.2, 10.1, 10.2_
  - [ ] 11.2 Create sign up screen
    - Build registration form with name, email, and password fields
    - Add role selection for new users
    - Implement password strength validation
    - Add terms and conditions acceptance
    - _Requirements: 1.1, 4.1, 4.3_
  - [ ] 11.3 Create password reset screen
    - Build password reset form with email input
    - Add email validation and submission
    - Display success/error messages
    - _Requirements: 11.5_

- [ ] 12. Build student UI screens and features
  - [ ] 12.1 Create student home dashboard
    - Build dashboard layout with quick stats (level, total quizzes, average score)
    - Add "Join Quiz" button prominently
    - Display recent quiz history with scores
    - Show recently earned badges
    - _Requirements: 4.4, 6.2, 6.3, 13.6_
  - [ ] 12.2 Create quiz PIN entry screen
    - Build PIN input field with numeric keyboard
    - Add PIN validation and quiz lookup
    - Display quiz details before starting (title, description, time limit, question count)
    - Add "Start Quiz" button
    - _Requirements: 5.1, 5.2_
  - [ ] 12.3 Create quiz taking screen with timer and security
    - Build question display with four option buttons
    - Implement countdown timer widget with visual progress
    - Add question navigation (current question number, total questions)
    - Integrate security monitoring (disable copy, detect tab/app switches)
    - Add auto-submit when time expires
    - Display violation warnings to student
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 15.1, 15.2, 15.3, 15.4, 15.5_
  - [ ] 12.4 Create quiz results screen
    - Display final score with percentage and pass/fail status
    - Show level up animation if student passed
    - Display newly earned badges with animations
    - Show correct vs incorrect answers breakdown
    - Add detailed answer review with correct answers highlighted
    - Add "Return to Home" and "View Leaderboard" buttons
    - _Requirements: 5.6, 6.3, 6.4, 7.2, 7.3, 13.4_
  - [ ] 12.5 Create progress dashboard screen
    - Build line chart showing score trends over time using fl_chart
    - Display key statistics cards (total quizzes, average score, current level, improvement trend)
    - Show pass/fail ratio with visual chart
    - Display recent quiz history list
    - Add filter options (last 10, last 30 days, all time)
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_
  - [ ] 12.6 Create leaderboard screen
    - Build global leaderboard list with rankings
    - Display student names, levels, and total scores
    - Highlight current user's position
    - Add pull-to-refresh functionality
    - Implement pagination for large leaderboards
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  - [ ] 12.7 Create badges screen
    - Display grid of all available badges
    - Show earned badges in color, locked badges in grayscale
    - Add badge details dialog with description and unlock criteria
    - Display progress towards next badge
    - _Requirements: 13.5, 13.6, 13.7_
  - [ ] 12.8 Create quiz-specific top 10 screen
    - Build top 10 list for specific quiz
    - Display student names, scores, completion times, and ranks
    - Highlight current user if in top 10
    - Add "Try Again" button to retake quiz
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 13. Build teacher UI screens and features
  - [ ] 13.1 Create teacher home dashboard
    - Build dashboard with quiz statistics (total quizzes created, total attempts, average scores)
    - Display list of created quizzes with quick actions (edit, delete, view analytics)
    - Add "Create New Quiz" floating action button
    - Show recent student activity
    - _Requirements: 2.5, 16.3_
  - [ ] 13.2 Create quiz creation screen
    - Build quiz form with title and description inputs
    - Add time limit input with optional toggle
    - Implement dynamic question list with add/remove functionality
    - Create question editor with text input and four option fields
    - Add correct answer selector (radio buttons)
    - Implement PIN input with auto-generate option
    - Add form validation for all required fields
    - Display generated PIN after creation
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.4_
  - [ ] 13.3 Create quiz edit screen
    - Reuse quiz creation form with pre-filled data
    - Add update and cancel buttons
    - Implement confirmation dialog for destructive changes
    - _Requirements: 2.5, 2.7_
  - [ ] 13.4 Create quiz analytics screen
    - Display quiz statistics (total attempts, average score, pass rate, completion rate)
    - Show top 10 students for this quiz
    - Display question-level analytics (most missed questions, average time per question)
    - Add chart showing score distribution
    - List all attempts with student names, scores, and violation flags
    - Add filter and sort options
    - _Requirements: 6.1, 8.1, 15.7, 16.1, 16.2, 16.4_
  - [ ] 13.5 Create student progress viewer screen
    - Build student search and selection interface
    - Display selected student's progress dashboard
    - Show student's earned badges
    - Display quiz history for that student
    - Add export functionality for student reports
    - _Requirements: 16.1, 16.2, 16.4_

- [ ] 14. Build admin UI screens and features
  - [ ] 14.1 Create admin dashboard
    - Build overview with platform statistics (total users, total quizzes, total attempts)
    - Display user breakdown by role (students, teachers, admins)
    - Show recent activity feed
    - Add quick action buttons for user and quiz management
    - _Requirements: 10.3, 11.1, 12.1_
  - [ ] 14.2 Create user management screen
    - Build user list with search and filter by role
    - Display user cards with name, email, role, and action buttons
    - Add edit user dialog for updating profile information
    - Implement delete user with confirmation dialog
    - Add password reset functionality
    - Show user statistics (quizzes taken/created, level for students)
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_
  - [ ] 14.3 Create quiz management screen
    - Build quiz list showing all quizzes from all teachers
    - Add search and filter by teacher
    - Display quiz cards with title, teacher name, and action buttons
    - Implement edit quiz functionality with admin override
    - Add delete quiz with confirmation and cascade warning
    - Add activate/deactivate toggle for quizzes
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  - [ ] 14.4 Create audit logs screen
    - Build log list with timestamps and admin actions
    - Add filter by admin, action type, and date range
    - Display security violations with student and quiz details
    - Implement log export functionality
    - _Requirements: 10.4, 15.8_

- [ ] 15. Implement adaptive UI components
  - Create AdaptiveButton widget with Material and Cupertino variants
  - Create AdaptiveScaffold widget with platform-specific app bars
  - Create AdaptiveDialog widget for alerts and confirmations
  - Create AdaptiveTextField widget with platform-specific styling
  - Implement platform detection utility
  - _Requirements: 17.2, 17.7_

- [ ] 16. Implement theme system
  - Create AppTheme class with Material Design 3 light and dark themes
  - Add Cupertino theme configuration for iOS
  - Implement dynamic color scheme generation from seed color
  - Add theme mode provider (light, dark, system)
  - Create custom color extensions for brand colors
  - _Requirements: 17.7_

- [ ] 17. Implement error handling and logging
  - Create AppException hierarchy with specific exception types
  - Implement global error handler with user-friendly messages
  - Integrate Firebase Crashlytics for crash reporting
  - Add error boundary widgets for graceful error display
  - Create logging utility for debugging
  - _Requirements: 1.4, 10.4_

- [ ] 18. Add biometric authentication support
  - Integrate local_auth package for fingerprint and face ID
  - Add biometric authentication option in login screen
  - Implement secure storage for biometric credentials
  - Add settings toggle for enabling/disabling biometric auth
  - _Requirements: 17.6_

- [ ] 19. Implement offline support and data synchronization
  - Add network connectivity monitoring
  - Implement offline mode indicator in UI
  - Create background sync service for pending operations
  - Add conflict resolution for offline changes
  - Implement retry logic for failed operations
  - _Requirements: 17.1_

- [ ] 20. Configure platform-specific builds
  - [ ] 20.1 Configure Android build
    - Set minSdkVersion to 32 in build.gradle
    - Configure app signing for release builds
    - Add ProGuard rules for code obfuscation
    - Configure app icons and splash screen
    - _Requirements: 17.3_
  - [ ] 20.2 Configure iOS build
    - Set minimum deployment target to 16.0 in Podfile
    - Configure app signing and provisioning profiles
    - Add app icons and launch screen
    - Configure Info.plist with required permissions
    - _Requirements: 17.4_
  - [ ] 20.3 Configure web build
    - Set up index.html with Firebase configuration
    - Configure web manifest for PWA support
    - Add favicon and app icons
    - Optimize build for production (tree shaking, minification)
    - _Requirements: 17.5_

- [ ] 21. Implement performance optimizations
  - Add lazy loading for quiz questions and leaderboards
  - Implement pagination for large lists
  - Add image caching with cached_network_image
  - Optimize Firestore queries with proper indexing
  - Implement debouncing for search inputs
  - Add loading skeletons for better perceived performance
  - _Requirements: 17.1, 17.2_

- [ ] 22. Write comprehensive tests
  - [ ] 22.1 Write unit tests for repositories
    - Test FirebaseAuthRepository authentication flows
    - Test FirebaseQuizRepository CRUD operations and PIN generation
    - Test FirebaseQuizAttemptRepository score calculation and violation tracking
    - Test FirebaseUserRepository level progression and leaderboard logic
    - Test FirebaseBadgeRepository badge awarding criteria
    - _Requirements: All repository-related requirements_
  - [ ] 22.2 Write unit tests for use cases
    - Test authentication use cases with various scenarios
    - Test quiz management use cases with permission validation
    - Test quiz participation use cases with score calculation
    - Test progress and leaderboard use cases with ranking logic
    - Test admin management use cases with authorization
    - _Requirements: All use case-related requirements_
  - [ ] 22.3 Write widget tests for UI components
    - Test authentication screens with form validation
    - Test quiz taking screen with timer and security features
    - Test progress dashboard with chart rendering
    - Test leaderboard with ranking display
    - Test admin screens with CRUD operations
    - _Requirements: All UI-related requirements_
  - [ ] 22.4 Write integration tests for complete flows
    - Test student quiz flow (login, join, take, complete, view results)
    - Test teacher quiz creation and management flow
    - Test admin user and quiz management flow
    - Test security violation detection and auto-submit
    - Test badge awarding after quiz completion
    - _Requirements: All end-to-end flow requirements_

- [ ] 23. Create app documentation and deployment guide
  - Write README with project setup instructions
  - Document Firebase configuration steps
  - Create user guide for teachers, students, and admins
  - Write deployment guide for Android, iOS, and web
  - Document environment variables and configuration
  - _Requirements: 17.1, 17.3, 17.4, 17.5_
