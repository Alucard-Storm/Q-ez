# Quiz Application Design Document

## Overview

The Quiz Application is a cross-platform Flutter application that enables teachers to create quizzes, students to participate and track progress, and administrators to manage the entire platform. The system implements role-based access control, gamification features, and anti-cheating security measures.

### Technology Stack

- **Framework**: Flutter 3.10+ with Dart 3.0+
- **State Management**: Riverpod 2.x for reactive state management
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **Local Storage**: Hive for offline caching and secure storage
- **Navigation**: GoRouter for declarative routing
- **UI**: Material Design 3 (Android) and Cupertino (iOS)

### Key Design Principles

1. **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
2. **Offline-First**: Local caching with background synchronization
3. **Security-First**: Multi-layered security with encryption and monitoring
4. **Responsive Design**: Adaptive UI for mobile, tablet, and web
5. **Testability**: Dependency injection and interface-based design

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Teacher    │  │   Student    │  │    Admin     │      │
│  │     UI       │  │     UI       │  │     UI       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │  View Models    │                        │
│                   │   (Riverpod)    │                        │
│                   └────────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────┐
│                      Domain Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Use Cases   │  │   Entities   │  │ Repositories │       │
│  │              │  │              │  │  (Abstract)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└────────────────────────────┬──────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────┐
│                       Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Firebase   │  │     Hive     │  │   Security   │       │
│  │  Repository  │  │  Repository  │  │   Monitor    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         │                  │                  │               │
│  ┌──────▼──────┐  ┌────────▼────────┐  ┌─────▼─────┐       │
│  │  Firestore  │  │  Local Storage  │  │  Security │       │
│  │  Cloud Fns  │  │   (Encrypted)   │  │   Logs    │       │
│  └─────────────┘  └─────────────────┘  └───────────┘       │
└───────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer
- UI widgets and screens
- User input handling
- State observation and UI updates
- Platform-specific adaptations

#### Domain Layer
- Business logic and rules
- Entity definitions
- Use case orchestration
- Repository interfaces

#### Data Layer
- Data source implementations
- API communication
- Local caching
- Data transformation

## Components and Interfaces

### Core Entities

#### User Entity
```dart
abstract class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastLoginAt;
}

class Student extends User {
  final int level;
  final List<String> badgeIds;
  final int totalQuizzesTaken;
  final double averageScore;
}

class Teacher extends User {
  final List<String> createdQuizIds;
}

class Admin extends User {
  final List<String> auditLogIds;
}

enum UserRole { student, teacher, admin }
```

#### Quiz Entity
```dart
class Quiz {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String pin;
  final int? timeLimitMinutes;
  final List<Question> questions;
  final DateTime createdAt;
  final bool isActive;
}

class Question {
  final String id;
  final String text;
  final List<String> options; // Always 4 options
  final int correctOptionIndex;
}
```

#### QuizAttempt Entity
```dart
class QuizAttempt {
  final String id;
  final String studentId;
  final String quizId;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final double score;
  final int totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int securityViolations;
  final List<SecurityViolation> violations;
  final bool isFlagged;
}

class SecurityViolation {
  final SecurityViolationType type;
  final DateTime timestamp;
}

enum SecurityViolationType { tabSwitch, appSwitch, copyAttempt }
```

#### Badge Entity
```dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final BadgeType type;
  final int requirement;
}

enum BadgeType {
  quizzesCompleted,
  perfectScore,
  levelReached,
}
```

### Repository Interfaces

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<User> signIn(String email, String password, UserRole role);
  Future<User> signUp(String email, String password, String name, UserRole role);
  Future<void> signOut();
  Stream<User?> authStateChanges();
  Future<void> resetPassword(String email);
}
```

#### QuizRepository
```dart
abstract class QuizRepository {
  Future<Quiz> createQuiz(Quiz quiz);
  Future<Quiz> getQuizByPin(String pin);
  Future<Quiz> getQuizById(String id);
  Future<List<Quiz>> getQuizzesByTeacher(String teacherId);
  Future<List<Quiz>> getAllQuizzes(); // Admin only
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(String id);
  Stream<List<Quiz>> watchQuizzes();
}
```

#### QuizAttemptRepository
```dart
abstract class QuizAttemptRepository {
  Future<QuizAttempt> startAttempt(String studentId, String quizId);
  Future<void> submitAnswer(String attemptId, String questionId, int selectedOption);
  Future<QuizAttempt> completeAttempt(String attemptId);
  Future<void> recordViolation(String attemptId, SecurityViolationType type);
  Future<List<QuizAttempt>> getStudentAttempts(String studentId);
  Future<List<QuizAttempt>> getQuizAttempts(String quizId);
  Stream<QuizAttempt> watchAttempt(String attemptId);
}
```

#### UserRepository
```dart
abstract class UserRepository {
  Future<Student> getStudent(String id);
  Future<void> updateStudentLevel(String id, int newLevel);
  Future<void> awardBadge(String studentId, String badgeId);
  Future<List<Student>> getLeaderboard(int limit);
  Future<List<Student>> getTopStudentsForQuiz(String quizId, int limit);
  Future<List<User>> getAllUsers(); // Admin only
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}
```

#### BadgeRepository
```dart
abstract class BadgeRepository {
  Future<List<Badge>> getAllBadges();
  Future<List<Badge>> getStudentBadges(String studentId);
  Future<void> checkAndAwardBadges(String studentId);
}
```

### Use Cases

#### Student Use Cases
- `SignInUseCase`: Authenticate student
- `JoinQuizUseCase`: Enter PIN and start quiz
- `SubmitAnswerUseCase`: Record answer and move to next question
- `CompleteQuizUseCase`: Calculate score, update level, award badges
- `GetProgressDashboardUseCase`: Fetch performance metrics and charts
- `GetLeaderboardUseCase`: Fetch global rankings
- `GetQuizTopStudentsUseCase`: Fetch top 10 for specific quiz

#### Teacher Use Cases
- `CreateQuizUseCase`: Create quiz with questions and settings
- `GeneratePinUseCase`: Auto-generate unique PIN
- `GetQuizAnalyticsUseCase`: Fetch quiz statistics
- `ViewStudentProgressUseCase`: Access student dashboards
- `UpdateQuizUseCase`: Edit quiz content
- `DeleteQuizUseCase`: Remove quiz

#### Admin Use Cases
- `ManageUsersUseCase`: CRUD operations on users
- `ManageQuizzesUseCase`: CRUD operations on all quizzes
- `ViewAuditLogsUseCase`: Access security and admin logs
- `ResetPasswordUseCase`: Reset user passwords

#### Security Use Cases
- `MonitorTabSwitchUseCase`: Detect and record tab changes
- `MonitorAppSwitchUseCase`: Detect and record app changes
- `DisableCopyUseCase`: Prevent text selection and copying
- `FlagSuspiciousAttemptUseCase`: Auto-flag attempts with violations

## Data Models

### Firestore Collections Structure

```
users/
  {userId}/
    - email: string
    - name: string
    - role: string
    - createdAt: timestamp
    - lastLoginAt: timestamp
    
    // Student-specific fields
    - level: number
    - badgeIds: array<string>
    - totalQuizzesTaken: number
    - averageScore: number
    
    // Teacher-specific fields
    - createdQuizIds: array<string>

quizzes/
  {quizId}/
    - title: string
    - description: string
    - teacherId: string
    - pin: string
    - timeLimitMinutes: number | null
    - createdAt: timestamp
    - isActive: boolean
    - questions: array<{
        id: string
        text: string
        options: array<string>
        correctOptionIndex: number
      }>

quiz_attempts/
  {attemptId}/
    - studentId: string
    - quizId: string
    - answers: map<string, number>
    - score: number
    - totalQuestions: number
    - startedAt: timestamp
    - completedAt: timestamp | null
    - securityViolations: number
    - violations: array<{
        type: string
        timestamp: timestamp
      }>
    - isFlagged: boolean

badges/
  {badgeId}/
    - name: string
    - description: string
    - iconAsset: string
    - type: string
    - requirement: number

leaderboard/
  global/
    - rankings: array<{
        studentId: string
        level: number
        totalScore: number
        rank: number
      }>
    - lastUpdated: timestamp

quiz_leaderboards/
  {quizId}/
    - rankings: array<{
        studentId: string
        score: number
        completedAt: timestamp
        rank: number
      }>
```

### Local Storage (Hive)

```dart
// Cached user data
@HiveType(typeId: 0)
class CachedUser {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String role;
  
  // Encrypted sensitive data
  @HiveField(4)
  String? encryptedToken;
}

// Cached quiz data for offline access
@HiveType(typeId: 1)
class CachedQuiz {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  List<CachedQuestion> questions;
  
  @HiveField(3)
  int? timeLimitMinutes;
}

// Security settings
@HiveType(typeId: 2)
class SecuritySettings {
  @HiveField(0)
  bool biometricEnabled;
  
  @HiveField(1)
  int maxViolations;
  
  @HiveField(2)
  bool strictMode;
}
```

## Security Implementation

### Authentication Flow

1. **Email/Password Authentication**: Firebase Authentication
2. **Role-Based Access**: Custom claims in Firebase Auth tokens
3. **Biometric Authentication**: local_auth package for fingerprint/face ID
4. **Session Management**: Automatic token refresh with secure storage

### Anti-Cheating System

#### Web Platform
```dart
class WebSecurityMonitor {
  void initialize() {
    // Disable right-click
    html.document.onContextMenu.listen((event) => event.preventDefault());
    
    // Disable text selection
    html.document.body?.style.userSelect = 'none';
    
    // Monitor tab visibility
    html.document.onVisibilityChange.listen(_handleVisibilityChange);
    
    // Disable copy shortcuts
    html.document.onKeyDown.listen(_handleKeyDown);
  }
  
  void _handleVisibilityChange(html.Event event) {
    if (html.document.hidden ?? false) {
      _recordViolation(SecurityViolationType.tabSwitch);
    }
  }
  
  void _handleKeyDown(html.KeyboardEvent event) {
    // Block Ctrl+C, Ctrl+X, Ctrl+A
    if (event.ctrlKey && ['c', 'x', 'a'].contains(event.key.toLowerCase())) {
      event.preventDefault();
      _recordViolation(SecurityViolationType.copyAttempt);
    }
  }
}
```

#### Mobile Platform
```dart
class MobileSecurityMonitor with WidgetsBindingObserver {
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      _recordViolation(SecurityViolationType.appSwitch);
    }
  }
  
  Widget buildSecureScreen(Widget child) {
    return SelectionArea(
      child: GestureDetector(
        onLongPress: () {}, // Disable long press
        child: child,
      ),
    );
  }
}
```

### Data Encryption

- **At Rest**: Hive encrypted boxes with AES-256
- **In Transit**: HTTPS/TLS for all network communication
- **Sensitive Fields**: Additional encryption for tokens and PINs

## UI/UX Design

### Navigation Structure

```
Root
├── Auth Flow
│   ├── Login Screen (role selection)
│   ├── Sign Up Screen
│   └── Password Reset Screen
│
├── Student Flow
│   ├── Home Dashboard
│   ├── Join Quiz (PIN entry)
│   ├── Quiz Taking Screen
│   ├── Results Screen
│   ├── Progress Dashboard
│   ├── Leaderboard Screen
│   └── Badges Screen
│
├── Teacher Flow
│   ├── Home Dashboard
│   ├── Create Quiz Screen
│   ├── Quiz List Screen
│   ├── Quiz Details/Edit Screen
│   ├── Quiz Analytics Screen
│   └── Student Progress Screen
│
└── Admin Flow
    ├── Dashboard
    ├── User Management Screen
    ├── Quiz Management Screen
    └── Audit Logs Screen
```

### Key UI Components

#### Adaptive Widgets
```dart
class AdaptiveButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(...)
        : FilledButton(...);
  }
}

class AdaptiveScaffold extends StatelessWidget {
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(...)
        : Scaffold(...);
  }
}
```

#### Quiz Timer Widget
```dart
class QuizTimer extends ConsumerWidget {
  final int totalMinutes;
  final VoidCallback onTimeUp;
  
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingSeconds = ref.watch(timerProvider);
    
    return CircularProgressIndicator(
      value: remainingSeconds / (totalMinutes * 60),
      child: Text('${remainingSeconds ~/ 60}:${remainingSeconds % 60}'),
    );
  }
}
```

#### Progress Chart Widget
```dart
class ProgressChart extends StatelessWidget {
  final List<QuizAttempt> attempts;
  
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: attempts.map((a) => 
              FlSpot(a.completedAt.millisecondsSinceEpoch.toDouble(), a.score)
            ).toList(),
          ),
        ],
      ),
    );
  }
}
```

### Theme Configuration

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
  
  static CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    brightness: Brightness.light,
  );
}
```

## State Management with Riverpod

### Provider Structure

```dart
// Auth providers
final authRepositoryProvider = Provider<AuthRepository>(...);
final authStateProvider = StreamProvider<User?>(...);
final currentUserProvider = FutureProvider<User?>(...);

// Quiz providers
final quizRepositoryProvider = Provider<QuizRepository>(...);
final quizListProvider = StreamProvider<List<Quiz>>(...);
final quizByPinProvider = FutureProvider.family<Quiz, String>(...);

// Quiz attempt providers
final activeAttemptProvider = StateNotifierProvider<AttemptNotifier, QuizAttempt?>(...);
final timerProvider = StateNotifierProvider<TimerNotifier, int>(...);
final securityMonitorProvider = Provider<SecurityMonitor>(...);

// Student providers
final studentProgressProvider = FutureProvider<ProgressData>(...);
final leaderboardProvider = FutureProvider<List<Student>>(...);
final badgesProvider = FutureProvider<List<Badge>>(...);

// Admin providers
final allUsersProvider = FutureProvider<List<User>>(...);
final auditLogsProvider = FutureProvider<List<AuditLog>>(...);
```

### State Notifiers

```dart
class AttemptNotifier extends StateNotifier<QuizAttempt?> {
  final QuizAttemptRepository _repository;
  
  AttemptNotifier(this._repository) : super(null);
  
  Future<void> startAttempt(String studentId, String quizId) async {
    state = await _repository.startAttempt(studentId, quizId);
  }
  
  Future<void> submitAnswer(String questionId, int option) async {
    if (state == null) return;
    await _repository.submitAnswer(state!.id, questionId, option);
  }
  
  Future<void> recordViolation(SecurityViolationType type) async {
    if (state == null) return;
    await _repository.recordViolation(state!.id, type);
    
    // Refresh state
    final updated = await _repository.getAttempt(state!.id);
    state = updated;
    
    // Auto-submit if violations >= 3
    if (updated.securityViolations >= 3) {
      await completeAttempt();
    }
  }
  
  Future<void> completeAttempt() async {
    if (state == null) return;
    state = await _repository.completeAttempt(state!.id);
  }
}

class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  final VoidCallback onTimeUp;
  
  TimerNotifier(int totalSeconds, this.onTimeUp) : super(totalSeconds);
  
  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (state <= 0) {
        timer.cancel();
        onTimeUp();
      } else {
        state = state - 1;
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

## Error Handling

### Error Types

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
}

class AuthException extends AppException {
  AuthException(String message, [String? code]) : super(message, code);
}

class QuizNotFoundException extends AppException {
  QuizNotFoundException(String pin) : super('Quiz not found with PIN: $pin');
}

class SecurityViolationException extends AppException {
  final int violationCount;
  
  SecurityViolationException(this.violationCount) 
      : super('Too many security violations: $violationCount');
}

class NetworkException extends AppException {
  NetworkException() : super('Network connection failed');
}
```

### Error Handling Strategy

```dart
class ErrorHandler {
  static void handle(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      _showUserFriendlyError(error);
    } else {
      _logError(error, stackTrace);
      _showGenericError();
    }
  }
  
  static void _showUserFriendlyError(AppException error) {
    // Show snackbar or dialog with error.message
  }
  
  static void _logError(Object error, StackTrace stackTrace) {
    // Log to Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

## Testing Strategy

### Unit Tests
- Repository implementations
- Use cases business logic
- State notifiers
- Utility functions
- Validation logic

### Widget Tests
- Individual UI components
- Screen layouts
- User interactions
- State changes

### Integration Tests
- Complete user flows
- Authentication flow
- Quiz creation and taking
- Leaderboard updates
- Badge awarding

### Test Structure

```dart
// Unit test example
void main() {
  group('QuizRepository', () {
    late QuizRepository repository;
    late MockFirestore mockFirestore;
    
    setUp(() {
      mockFirestore = MockFirestore();
      repository = FirebaseQuizRepository(mockFirestore);
    });
    
    test('createQuiz generates PIN when not provided', () async {
      final quiz = Quiz(title: 'Test', pin: '');
      final created = await repository.createQuiz(quiz);
      
      expect(created.pin, isNotEmpty);
      expect(created.pin.length, equals(6));
    });
  });
}

// Widget test example
void main() {
  testWidgets('QuizTimer displays remaining time', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: QuizTimer(totalMinutes: 10, onTimeUp: () {}),
      ),
    );
    
    expect(find.text('10:00'), findsOneWidget);
  });
}

// Integration test example
void main() {
  group('Student Quiz Flow', () {
    testWidgets('complete quiz flow', (tester) async {
      // 1. Login as student
      // 2. Enter quiz PIN
      // 3. Answer questions
      // 4. Submit quiz
      // 5. Verify results displayed
      // 6. Verify level updated
    });
  });
}
```

## Performance Optimization

### Strategies

1. **Lazy Loading**: Load quiz questions on-demand
2. **Pagination**: Implement pagination for leaderboards and quiz lists
3. **Caching**: Cache frequently accessed data locally
4. **Image Optimization**: Use cached_network_image for badge icons
5. **Debouncing**: Debounce search and filter operations
6. **Background Sync**: Sync data in background when online

### Firebase Optimization

```dart
// Use indexes for common queries
// Firestore indexes:
// - quiz_attempts: (studentId, completedAt DESC)
// - quiz_attempts: (quizId, score DESC, completedAt ASC)
// - users: (role, level DESC, averageScore DESC)

// Batch operations
Future<void> awardMultipleBadges(String studentId, List<String> badgeIds) async {
  final batch = FirebaseFirestore.instance.batch();
  
  for (final badgeId in badgeIds) {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(studentId);
    batch.update(ref, {
      'badgeIds': FieldValue.arrayUnion([badgeId])
    });
  }
  
  await batch.commit();
}
```

## Deployment Configuration

### Build Configurations

```yaml
# pubspec.yaml
name: q_ez
description: Q-ez - A cross-platform quiz application
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.2.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_crashlytics: ^3.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Security
  local_auth: ^2.1.7
  flutter_secure_storage: ^9.0.0
  
  # UI
  fl_chart: ^0.65.0
  cached_network_image: ^3.3.0
  
  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  mockito: ^5.4.3
```

### Platform-Specific Configuration

#### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 32
        targetSdkVersion 34
    }
}
```

#### iOS (ios/Podfile)
```ruby
platform :ios, '16.0'
```

### Environment Variables

```dart
class Environment {
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
}
```

## Future Enhancements

1. **Real-time Multiplayer**: Live quiz competitions
2. **AI-Generated Questions**: Auto-generate questions from topics
3. **Voice Questions**: Audio-based questions for accessibility
4. **Offline Mode**: Complete quizzes offline and sync later
5. **Analytics Dashboard**: Advanced teacher analytics with ML insights
6. **Social Features**: Friend challenges and sharing
7. **Custom Themes**: User-customizable color schemes
8. **Accessibility**: Screen reader support and high contrast modes
