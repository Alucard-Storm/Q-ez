# Firestore Database Schema

This document defines the Firestore collections structure for the Q-ez Quiz Application.

## Collections Overview

- `users` - User profiles (students, teachers, admins)
- `quizzes` - Quiz definitions with questions
- `quiz_attempts` - Student quiz attempts and results
- `badges` - Achievement badges definitions
- `leaderboard` - Global leaderboard data
- `quiz_leaderboards` - Per-quiz leaderboard data
- `audit_logs` - Admin action logs

---

## Collection: `users`

Stores user profiles for all roles (student, teacher, admin).

### Document ID
User's Firebase Auth UID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | User's unique identifier (same as document ID) |
| `email` | string | Yes | User's email address |
| `name` | string | Yes | User's display name |
| `role` | string | Yes | User role: 'student', 'teacher', or 'admin' |
| `createdAt` | timestamp | Yes | Account creation timestamp |
| `lastLoginAt` | timestamp | Yes | Last login timestamp |

### Student-Specific Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `level` | number | Yes | Current student level (starts at 1) |
| `badgeIds` | array<string> | Yes | Array of earned badge IDs |
| `totalQuizzesTaken` | number | Yes | Total number of completed quizzes |
| `averageScore` | number | Yes | Average score across all quizzes (0-100) |

### Teacher-Specific Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `createdQuizIds` | array<string> | Yes | Array of quiz IDs created by this teacher |

### Admin-Specific Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `auditLogIds` | array<string> | No | Array of audit log IDs for this admin |

### Example Document

```json
{
  "id": "abc123",
  "email": "student@example.com",
  "name": "John Doe",
  "role": "student",
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLoginAt": "2024-01-20T14:45:00Z",
  "level": 5,
  "badgeIds": ["badge1", "badge2", "badge3"],
  "totalQuizzesTaken": 12,
  "averageScore": 78.5
}
```

### Indexes

- Composite: `role` (ASC) + `level` (DESC) + `averageScore` (DESC)
  - Used for: Global leaderboard queries

---

## Collection: `quizzes`

Stores quiz definitions created by teachers.

### Document ID
Auto-generated Firestore document ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Quiz unique identifier (same as document ID) |
| `title` | string | Yes | Quiz title |
| `description` | string | Yes | Quiz description |
| `teacherId` | string | Yes | ID of teacher who created the quiz |
| `pin` | string | Yes | Unique 6-digit PIN for joining quiz |
| `timeLimitMinutes` | number | No | Time limit in minutes (null = no limit) |
| `createdAt` | timestamp | Yes | Quiz creation timestamp |
| `isActive` | boolean | Yes | Whether quiz is active/available |
| `questions` | array<object> | Yes | Array of question objects |

### Question Object Structure

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Question unique identifier |
| `text` | string | Yes | Question text |
| `options` | array<string> | Yes | Array of 4 answer options |
| `correctOptionIndex` | number | Yes | Index of correct answer (0-3) |

### Example Document

```json
{
  "id": "quiz123",
  "title": "JavaScript Basics",
  "description": "Test your knowledge of JavaScript fundamentals",
  "teacherId": "teacher456",
  "pin": "123456",
  "timeLimitMinutes": 30,
  "createdAt": "2024-01-15T10:00:00Z",
  "isActive": true,
  "questions": [
    {
      "id": "q1",
      "text": "What is the output of typeof null?",
      "options": ["null", "undefined", "object", "number"],
      "correctOptionIndex": 2
    },
    {
      "id": "q2",
      "text": "Which keyword declares a constant?",
      "options": ["var", "let", "const", "final"],
      "correctOptionIndex": 2
    }
  ]
}
```

### Indexes

- Single field: `pin` (ASC)
  - Used for: Finding quiz by PIN
- Composite: `teacherId` (ASC) + `createdAt` (DESC)
  - Used for: Teacher's quiz list
- Composite: `isActive` (ASC) + `createdAt` (DESC)
  - Used for: Active quizzes list

---

## Collection: `quiz_attempts`

Stores student quiz attempts and results.

### Document ID
Auto-generated Firestore document ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Attempt unique identifier |
| `studentId` | string | Yes | ID of student taking the quiz |
| `quizId` | string | Yes | ID of the quiz being attempted |
| `answers` | map<string, number> | Yes | Map of questionId to selected option index |
| `score` | number | Yes | Final score (0-100) |
| `totalQuestions` | number | Yes | Total number of questions in quiz |
| `startedAt` | timestamp | Yes | When quiz attempt started |
| `completedAt` | timestamp | No | When quiz was completed (null if in progress) |
| `securityViolations` | number | Yes | Count of security violations |
| `violations` | array<object> | Yes | Array of violation objects |
| `isFlagged` | boolean | Yes | Whether attempt is flagged as suspicious |

### Violation Object Structure

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Violation type: 'tabSwitch', 'appSwitch', 'copyAttempt' |
| `timestamp` | timestamp | Yes | When violation occurred |

### Example Document

```json
{
  "id": "attempt789",
  "studentId": "student123",
  "quizId": "quiz456",
  "answers": {
    "q1": 2,
    "q2": 1,
    "q3": 0
  },
  "score": 66.67,
  "totalQuestions": 3,
  "startedAt": "2024-01-20T14:00:00Z",
  "completedAt": "2024-01-20T14:25:00Z",
  "securityViolations": 1,
  "violations": [
    {
      "type": "tabSwitch",
      "timestamp": "2024-01-20T14:10:00Z"
    }
  ],
  "isFlagged": false
}
```

### Indexes

- Composite: `studentId` (ASC) + `completedAt` (DESC)
  - Used for: Student's quiz history
- Composite: `quizId` (ASC) + `score` (DESC) + `completedAt` (ASC)
  - Used for: Quiz leaderboard (top 10 students)
- Composite: `quizId` (ASC) + `isFlagged` (ASC) + `completedAt` (DESC)
  - Used for: Flagged attempts for a quiz

---

## Collection: `badges`

Stores achievement badge definitions.

### Document ID
Auto-generated Firestore document ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Badge unique identifier |
| `name` | string | Yes | Badge name |
| `description` | string | Yes | Badge description |
| `iconAsset` | string | Yes | Path to badge icon asset |
| `type` | string | Yes | Badge type: 'quizzesCompleted', 'perfectScore', 'levelReached' |
| `requirement` | number | Yes | Requirement value (e.g., 10 for "Complete 10 quizzes") |

### Example Document

```json
{
  "id": "badge1",
  "name": "Quiz Novice",
  "description": "Complete your first quiz",
  "iconAsset": "assets/badges/novice.png",
  "type": "quizzesCompleted",
  "requirement": 1
}
```

### Predefined Badges

| Name | Type | Requirement | Description |
|------|------|-------------|-------------|
| Quiz Novice | quizzesCompleted | 1 | Complete 1 quiz |
| Quiz Enthusiast | quizzesCompleted | 5 | Complete 5 quizzes |
| Quiz Expert | quizzesCompleted | 10 | Complete 10 quizzes |
| Quiz Master | quizzesCompleted | 25 | Complete 25 quizzes |
| Quiz Legend | quizzesCompleted | 50 | Complete 50 quizzes |
| Perfect Score | perfectScore | 1 | Achieve 100% on any quiz |
| Level 5 | levelReached | 5 | Reach level 5 |
| Level 10 | levelReached | 10 | Reach level 10 |
| Level 25 | levelReached | 25 | Reach level 25 |
| Level 50 | levelReached | 50 | Reach level 50 |

---

## Collection: `leaderboard`

Stores global leaderboard data.

### Document ID
Fixed: `global`

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `rankings` | array<object> | Yes | Array of student ranking objects |
| `lastUpdated` | timestamp | Yes | Last update timestamp |

### Ranking Object Structure

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `studentId` | string | Yes | Student's user ID |
| `level` | number | Yes | Student's current level |
| `totalScore` | number | Yes | Total score across all quizzes |
| `rank` | number | Yes | Current rank position |

### Example Document

```json
{
  "rankings": [
    {
      "studentId": "student1",
      "level": 15,
      "totalScore": 1250,
      "rank": 1
    },
    {
      "studentId": "student2",
      "level": 12,
      "totalScore": 980,
      "rank": 2
    }
  ],
  "lastUpdated": "2024-01-20T15:00:00Z"
}
```

---

## Collection: `quiz_leaderboards`

Stores per-quiz leaderboard data.

### Document ID
Quiz ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `rankings` | array<object> | Yes | Array of top 10 student rankings |
| `lastUpdated` | timestamp | Yes | Last update timestamp |

### Ranking Object Structure

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `studentId` | string | Yes | Student's user ID |
| `score` | number | Yes | Score on this quiz |
| `completedAt` | timestamp | Yes | When quiz was completed |
| `rank` | number | Yes | Rank position (1-10) |

### Example Document

```json
{
  "rankings": [
    {
      "studentId": "student1",
      "score": 100,
      "completedAt": "2024-01-20T14:30:00Z",
      "rank": 1
    },
    {
      "studentId": "student2",
      "score": 95,
      "completedAt": "2024-01-20T14:35:00Z",
      "rank": 2
    }
  ],
  "lastUpdated": "2024-01-20T15:00:00Z"
}
```

---

## Collection: `audit_logs`

Stores admin action logs for security and compliance.

### Document ID
Auto-generated Firestore document ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Log entry unique identifier |
| `adminId` | string | Yes | ID of admin who performed action |
| `action` | string | Yes | Action type (e.g., 'deleteUser', 'updateQuiz') |
| `targetType` | string | Yes | Type of target: 'user', 'quiz', 'attempt' |
| `targetId` | string | Yes | ID of affected entity |
| `details` | map | No | Additional action details |
| `timestamp` | timestamp | Yes | When action occurred |

### Example Document

```json
{
  "id": "log123",
  "adminId": "admin456",
  "action": "deleteUser",
  "targetType": "user",
  "targetId": "student789",
  "details": {
    "reason": "Policy violation",
    "userEmail": "student@example.com"
  },
  "timestamp": "2024-01-20T16:00:00Z"
}
```

---

## Security Rules

Security rules are defined in `firestore.rules` and enforce:

1. **Authentication**: All operations require authentication
2. **Role-Based Access Control**:
   - Students: Can read/write their own data, read quizzes and badges
   - Teachers: Can manage their own quizzes, view student progress
   - Admins: Full access to all collections
3. **Data Validation**: Ensures data integrity and proper field types
4. **Ownership**: Users can only modify their own data (except admins)

## Indexes

Indexes are defined in `firestore.indexes.json` and optimize:

1. Leaderboard queries (by level and score)
2. Quiz lookup by PIN
3. Student quiz history
4. Quiz top performers
5. Teacher's quiz list
6. Flagged attempts

## Deployment

Deploy security rules and indexes:

```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

## Data Migration

For initial setup, seed the badges collection with predefined badges using a Cloud Function or admin script.
