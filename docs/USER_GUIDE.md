# Q-ez User Guide

This guide covers how to use Q-ez for each of the three user roles: **Student**, **Teacher**, and **Admin**.

---

## Table of Contents

- [Getting Started — All Roles](#getting-started--all-roles)
- [Student Guide](#student-guide)
  - [Registration and Login](#student-registration-and-login)
  - [Joining a Quiz](#joining-a-quiz)
  - [Taking a Quiz](#taking-a-quiz)
  - [Viewing Results](#viewing-results)
  - [Progress Dashboard](#progress-dashboard)
  - [Leaderboard](#leaderboard)
  - [Achievement Badges](#achievement-badges)
- [Teacher Guide](#teacher-guide)
  - [Registration and Login](#teacher-registration-and-login)
  - [Creating a Quiz](#creating-a-quiz)
  - [Editing and Deleting Quizzes](#editing-and-deleting-quizzes)
  - [Viewing Quiz Analytics](#viewing-quiz-analytics)
  - [Monitoring Student Progress](#monitoring-student-progress)
- [Admin Guide](#admin-guide)
  - [Admin Login](#admin-login)
  - [Dashboard Overview](#dashboard-overview)
  - [User Management](#user-management)
  - [Quiz Management](#quiz-management)
  - [Audit Logs](#audit-logs)

---

## Getting Started — All Roles

### Supported Platforms

| Platform | Minimum Version |
|----------|----------------|
| Android | Android 12L (API 32) |
| iOS | iOS 16.0 |
| Web | Chrome, Firefox, Safari (ES6+) |

### Account Registration

1. Open Q-ez on your device or browser.
2. On the login screen, tap **Sign Up**.
3. Enter your name, email address, and a password (minimum 8 characters).
4. Select your role: **Student**, **Teacher**, or **Admin**.
5. Tap **Create Account**.

> Admin accounts are typically provisioned by an existing administrator. Contact your platform admin if you need admin access.

### Logging In

1. Open Q-ez.
2. Enter your email and password.
3. Select your role from the role selector.
4. Tap **Log In**.

### Biometric Login

If your device supports fingerprint or Face ID, you can enable biometric login:

1. Log in with your email and password at least once.
2. Go to **Settings** and enable **Biometric Authentication**.
3. On subsequent logins, tap the biometric icon to authenticate without a password.

### Forgot Password

1. On the login screen, tap **Forgot Password**.
2. Enter your registered email address.
3. Check your inbox for a password reset link.

---

## Student Guide

### Student Registration and Login

When you create a Student account, your profile is initialized with:
- **Level 1** — your starting level
- **0 quizzes completed**
- **No badges** (yet)

Your level increases by 1 each time you pass a quiz (score ≥ 60%).

### Joining a Quiz

1. From the **Home Dashboard**, tap **Join Quiz**.
2. Enter the 6-digit PIN provided by your teacher.
3. The quiz details screen shows the quiz title, description, number of questions, and time limit (if any).
4. Tap **Start Quiz** when you are ready.

> The timer starts immediately when you tap Start Quiz. Make sure you are ready before proceeding.

### Taking a Quiz

- Questions are displayed one at a time with four answer options.
- Tap an option to select it. Your selection is highlighted.
- Tap **Next** to move to the following question.
- The **progress bar** at the top shows how many questions remain.
- If the quiz has a time limit, a **countdown timer** is displayed prominently. When time runs out, the quiz is submitted automatically with all answers recorded so far.

#### Anti-Cheating Rules

Q-ez monitors for suspicious activity during a quiz:

| Action | What Happens |
|--------|-------------|
| Switching browser tabs | Violation recorded |
| Switching to another app (mobile) | Violation recorded |
| Attempting to copy text (web) | Violation recorded |
| Right-clicking (web) | Blocked |
| 3 or more violations | Quiz auto-submitted and flagged |

Each violation triggers a warning banner. After 3 violations, the quiz is submitted immediately regardless of progress.

### Viewing Results

After completing a quiz, the **Results Screen** shows:

- Your **score** as a percentage and raw count (e.g., 8/10 — 80%)
- **Pass / Fail** status (passing threshold: 60%)
- **Level up** animation if you passed and your level increased
- **Newly earned badges** with unlock animations
- A breakdown of correct vs. incorrect answers
- Detailed answer review — each question shows your answer and the correct answer

From the results screen you can:
- Tap **Return to Home** to go back to the dashboard
- Tap **View Leaderboard** to see the top 10 for this quiz

### Progress Dashboard

Access the Progress Dashboard from the bottom navigation bar or the **Home Dashboard**.

The dashboard displays:

- **Score trend chart** — a line chart of your scores over time
- **Key statistics** — total quizzes completed, average score, current level, improvement trend (% change over last 10 quizzes)
- **Pass/Fail ratio** — visual chart of your pass and fail counts
- **Recent quiz history** — list of your last attempts with scores and dates

Use the filter options to view data for the last 10 quizzes, last 30 days, or all time.

### Leaderboard

The **Global Leaderboard** ranks all students by level, then by total score for students at the same level.

1. Tap **Leaderboard** in the navigation bar.
2. Your position is highlighted in the list.
3. Pull down to refresh rankings.

The leaderboard updates immediately after any student completes a quiz.

### Per-Quiz Top 10

After completing a quiz, or from the quiz results screen, tap **View Leaderboard** to see the top 10 students for that specific quiz. Rankings are ordered by score (highest first), with completion time as a tiebreaker.

### Achievement Badges

Badges are awarded automatically when you meet the criteria. View all badges from the **Badges** screen in the navigation bar.

| Badge | Criteria |
|-------|---------|
| Quiz Novice | Complete 1 quiz |
| Quiz Enthusiast | Complete 5 quizzes |
| Quiz Expert | Complete 10 quizzes |
| Quiz Master | Complete 25 quizzes |
| Quiz Legend | Complete 50 quizzes |
| Perfect Score | Achieve 100% on any quiz |
| Level 5 | Reach level 5 |
| Level 10 | Reach level 10 |
| Level 25 | Reach level 25 |
| Level 50 | Reach level 50 |

- **Earned badges** are shown in full color.
- **Locked badges** are shown in grayscale with the unlock criteria.
- Tap any badge to see its description and your progress toward unlocking it.

---

## Teacher Guide

### Teacher Registration and Login

Register with the **Teacher** role selected. After logging in, you are taken to the Teacher Dashboard, which shows your created quizzes and recent student activity.

### Creating a Quiz

1. From the Teacher Dashboard, tap the **+** (Create New Quiz) button.
2. Fill in the quiz details:
   - **Title** (required)
   - **Description** (required)
   - **Time Limit** — toggle on and enter minutes, or leave off for no time limit
   - **PIN** — enter a custom 6-digit PIN, or leave blank to auto-generate one
3. Add questions using the **Add Question** button:
   - Enter the question text
   - Fill in all four answer options
   - Select the correct answer using the radio button
4. Repeat for each question (minimum 1 question required).
5. Tap **Create Quiz**.

The quiz PIN is displayed on the confirmation screen. Share this PIN with your students.

> PINs must be unique across all active quizzes. If you enter a PIN that is already in use, you will be prompted to choose a different one.

### Editing and Deleting Quizzes

**To edit a quiz:**
1. From the Teacher Dashboard, find the quiz in your list.
2. Tap the **Edit** (pencil) icon.
3. Modify any fields or questions.
4. Tap **Save Changes**.

**To delete a quiz:**
1. Tap the **Delete** (trash) icon next to the quiz.
2. Confirm the deletion in the dialog.

> Deleting a quiz removes all associated student attempts and results. This action cannot be undone.

### Viewing Quiz Analytics

Tap the **Analytics** icon on any quiz card to open the Quiz Analytics screen:

- **Summary stats** — total attempts, average score, pass rate, completion rate
- **Top 10 students** for this quiz
- **Question-level analytics** — which questions were most frequently missed
- **Score distribution chart**
- **All attempts list** — student names, scores, completion times, and violation flags

Use the filter and sort options to narrow down results by date or score range.

### Monitoring Student Progress

1. From the Teacher Dashboard, tap **Student Progress**.
2. Search for a student by name or email.
3. Select a student to view their full Progress Dashboard, including:
   - Score trend chart
   - Key statistics (level, average score, total quizzes)
   - Earned badges
   - Quiz history

You can export a student's progress report using the **Export** button on the student progress screen.

---

## Admin Guide

### Admin Login

Admin accounts use the same login screen as other roles. Select **Admin** from the role selector and enter your credentials.

> Admin credentials should be kept secure. Admin accounts have full access to all platform data.

### Dashboard Overview

The Admin Dashboard provides a platform-wide overview:

- **Total users** broken down by role (students, teachers, admins)
- **Total quizzes** and **total quiz attempts**
- **Recent activity feed** showing the latest user and quiz actions
- Quick action buttons for **User Management** and **Quiz Management**

### User Management

Access **User Management** from the Admin Dashboard or the navigation menu.

**Viewing users:**
- The user list shows all accounts with name, email, role, and status.
- Use the search bar to find users by name or email.
- Filter by role using the role filter chips.

**Editing a user:**
1. Tap the **Edit** icon on a user card.
2. Update the user's name, email, or role in the dialog.
3. Tap **Save**.

**Deleting a user:**
1. Tap the **Delete** icon on a user card.
2. Confirm the deletion.

> Deleting a student account removes all their quiz history and leaderboard entries. Deleting a teacher account does not automatically delete their quizzes.

**Resetting a password:**
1. Tap the **Reset Password** option on a user card.
2. A password reset email is sent to the user's registered email address.

### Quiz Management

Access **Quiz Management** from the Admin Dashboard.

- View all quizzes from all teachers in a searchable, filterable list.
- Filter by teacher name using the teacher filter.
- **Edit** any quiz (admin override — not restricted to the quiz creator).
- **Delete** any quiz with a confirmation dialog that warns about cascade deletion of attempts.
- **Activate / Deactivate** a quiz using the toggle switch on the quiz card. Deactivated quizzes cannot be joined by students but are not deleted.

### Audit Logs

Access **Audit Logs** from the Admin Dashboard or navigation menu.

The audit log records all administrative actions with:
- Timestamp
- Admin who performed the action
- Action type (e.g., `deleteUser`, `updateQuiz`, `deactivateQuiz`)
- Target entity (user ID, quiz ID, etc.)
- Additional details

**Filtering logs:**
- Filter by admin, action type, or date range using the filter controls at the top.
- Security violations (tab switches, copy attempts) are also visible here with student and quiz details.

**Exporting logs:**
- Tap the **Export** button to download the filtered log as a CSV file.
