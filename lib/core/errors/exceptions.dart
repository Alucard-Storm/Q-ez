/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message, [super.code]);

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Quiz related exceptions
class QuizException extends AppException {
  QuizException(super.message, [super.code]);

  @override
  String toString() => 'QuizException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when a quiz is not found
class QuizNotFoundException extends QuizException {
  QuizNotFoundException(String identifier)
      : super('Quiz not found: $identifier');

  @override
  String toString() => 'QuizNotFoundException: $message';
}

/// Quiz attempt related exceptions
class QuizAttemptException extends AppException {
  QuizAttemptException(super.message, [super.code]);

  @override
  String toString() => 'QuizAttemptException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when a quiz attempt is not found
class QuizAttemptNotFoundException extends QuizAttemptException {
  QuizAttemptNotFoundException(String attemptId)
      : super('Quiz attempt not found: $attemptId');

  @override
  String toString() => 'QuizAttemptNotFoundException: $message';
}

/// Exception thrown when security violations exceed threshold
class SecurityViolationException extends QuizAttemptException {
  final int violationCount;

  SecurityViolationException(this.violationCount)
      : super('Too many security violations: $violationCount');

  @override
  String toString() => 'SecurityViolationException: $message';
}

/// User related exceptions
class UserException extends AppException {
  UserException(super.message, [super.code]);

  @override
  String toString() => 'UserException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when a user is not found
class UserNotFoundException extends UserException {
  UserNotFoundException(String userId)
      : super('User not found: $userId');

  @override
  String toString() => 'UserNotFoundException: $message';
}

/// Badge related exceptions
class BadgeException extends AppException {
  BadgeException(super.message, [super.code]);

  @override
  String toString() => 'BadgeException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when a badge is not found
class BadgeNotFoundException extends BadgeException {
  BadgeNotFoundException(String badgeId)
      : super('Badge not found: $badgeId');

  @override
  String toString() => 'BadgeNotFoundException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException([String message = 'Network connection failed'])
      : super(message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Permission related exceptions
class PermissionException extends AppException {
  PermissionException([String message = 'Permission denied'])
      : super(message);

  @override
  String toString() => 'PermissionException: $message';
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(super.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Cache related exceptions
class CacheException extends AppException {
  CacheException([String message = 'Cache operation failed'])
      : super(message);

  @override
  String toString() => 'CacheException: $message';
}
