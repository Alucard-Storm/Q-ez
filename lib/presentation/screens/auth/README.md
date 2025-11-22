# Authentication Screens

This directory contains the authentication UI screens for the Q-ez Quiz Application.

## Screens

### 1. LoginScreen (`login_screen.dart`)
The main authentication entry point for users.

**Features:**
- Email and password input fields with validation
- Role selection (Student, Teacher, Admin) using segmented buttons
- Password visibility toggle
- Form validation with user-friendly error messages
- Navigation to sign up and password reset screens
- Loading state with disabled inputs during authentication
- Adaptive Material Design 3 UI

**Requirements Covered:**
- 1.1, 1.2: Teacher authentication
- 4.1, 4.2: Student authentication
- 10.1, 10.2: Admin authentication

### 2. SignUpScreen (`sign_up_screen.dart`)
User registration screen for creating new accounts.

**Features:**
- Full name, email, and password input fields
- Role selection for new users
- Password strength validation with visual indicator
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
- Password confirmation field
- Terms and conditions acceptance checkbox
- Real-time password strength feedback (Weak/Medium/Strong)
- Form validation with detailed error messages
- Loading state during registration

**Requirements Covered:**
- 1.1: Teacher registration
- 4.1: Student registration
- 4.3: Initial profile setup

### 3. PasswordResetScreen (`password_reset_screen.dart`)
Password recovery screen for users who forgot their credentials.

**Features:**
- Email input for password reset
- Email validation
- Success state with confirmation message
- Resend email functionality
- Helpful tips for users who don't receive the email
- Back to login navigation
- User-friendly error handling

**Requirements Covered:**
- 11.5: Password reset functionality

## Usage

All screens are automatically integrated with the app router and can be navigated to using:

```dart
// Navigate to login
context.go(Routes.login);

// Navigate to sign up
context.push(Routes.signUp);

// Navigate to password reset
context.push(Routes.passwordReset);
```

## State Management

All screens use Riverpod for state management and interact with:
- `authRepositoryProvider`: For authentication operations
- `authStateProvider`: For reactive auth state changes

## Navigation Flow

```
LoginScreen
├── → SignUpScreen (via "Sign Up" button)
├── → PasswordResetScreen (via "Forgot Password?" link)
└── → Role-based home (automatic after successful login)
    ├── Student → /student/home
    ├── Teacher → /teacher/home
    └── Admin → /admin/home

SignUpScreen
├── → LoginScreen (via back button or "Login" link)
└── → Role-based home (automatic after successful registration)

PasswordResetScreen
└── → LoginScreen (via back button or "Back to Login" button)
```

## Error Handling

All screens implement comprehensive error handling:
- Network errors
- Invalid credentials
- Email already in use
- Weak passwords
- Too many requests
- Role mismatch errors

Error messages are user-friendly and provide actionable guidance.

## Design

- Material Design 3 with adaptive theming
- Responsive layout that works on mobile, tablet, and web
- Consistent spacing and typography
- Accessible form controls with proper labels
- Visual feedback for all user actions
- Loading states to prevent duplicate submissions
