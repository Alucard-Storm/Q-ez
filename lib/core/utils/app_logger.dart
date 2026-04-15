import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Log levels for the application logger
enum LogLevel { debug, info, warning, error }

/// Application-wide logging utility with Crashlytics integration
class AppLogger {
  static const String _tag = 'Q-ez';

  /// Log a debug message (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an informational message
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message and send a non-fatal event to Crashlytics
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
    if (error != null) {
      _recordNonFatal(error, stackTrace ?? StackTrace.current);
    }
  }

  /// Log an error and record it in Crashlytics
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
    if (error != null) {
      _recordNonFatal(error, stackTrace ?? StackTrace.current);
    }
  }

  /// Set a custom key in Crashlytics for better crash context
  static void setCustomKey(String key, Object value) {
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }

  /// Set the current user identifier in Crashlytics
  static void setUserId(String userId) {
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (_) {}
  }

  /// Log a breadcrumb message to Crashlytics for crash context
  static void breadcrumb(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
    if (kDebugMode) {
      debugPrint('[$_tag][BREADCRUMB] $message');
    }
  }

  static void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final prefix = switch (level) {
      LogLevel.debug => '🔍 DEBUG',
      LogLevel.info => 'ℹ️  INFO',
      LogLevel.warning => '⚠️  WARN',
      LogLevel.error => '❌ ERROR',
    };

    final buffer = StringBuffer('[$_tag][$prefix] $message');
    if (error != null) buffer.write('\n  Error: $error');
    if (stackTrace != null && level == LogLevel.error) {
      buffer.write('\n  StackTrace: $stackTrace');
    }

    debugPrint(buffer.toString());
  }

  static void _recordNonFatal(Object error, StackTrace stackTrace) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: false,
      );
    } catch (_) {}
  }
}
