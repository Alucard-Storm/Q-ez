import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'exceptions.dart';
import '../utils/app_logger.dart';

/// Global error handler that provides user-friendly messages and logs errors
class ErrorHandler {
  /// Handle an error and optionally show a message via a [BuildContext]
  static void handle(
    Object error,
    StackTrace stackTrace, {
    BuildContext? context,
  }) {
    if (error is AppException) {
      AppLogger.warning('AppException: ${error.message}', error, stackTrace);
      if (context != null && context.mounted) {
        _showUserFriendlyError(context, error);
      }
    } else {
      AppLogger.error('Unhandled error', error, stackTrace);
      _logToCrashlytics(error, stackTrace);
      if (context != null && context.mounted) {
        _showGenericError(context);
      }
    }
  }

  /// Get a user-friendly message for an [AppException]
  static String getUserMessage(AppException error) {
    return switch (error) {
      AuthException() => error.message,
      QuizNotFoundException() => 'Quiz not found. Please check the PIN and try again.',
      QuizException() => error.message,
      SecurityViolationException() =>
        'Your quiz was submitted due to too many security violations.',
      QuizAttemptException() => error.message,
      UserNotFoundException() => 'User not found.',
      UserException() => error.message,
      BadgeNotFoundException() => 'Badge not found.',
      BadgeException() => error.message,
      NetworkException() => 'No internet connection. Please check your network and try again.',
      PermissionException() => 'You do not have permission to perform this action.',
      ValidationException() => error.message,
      CacheException() => 'A local storage error occurred. Please try again.',
      _ => error.message,
    };
  }

  static void _showUserFriendlyError(BuildContext context, AppException error) {
    final message = getUserMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showGenericError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('An unexpected error occurred. Please try again.'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _logToCrashlytics(Object error, StackTrace stackTrace) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } catch (_) {
      // Crashlytics may not be available in all environments
    }
  }
}
