import 'dart:async';
import 'dart:math';
import 'app_logger.dart';

/// Provides exponential backoff retry logic for async operations.
///
/// Usage:
/// ```dart
/// final result = await RetryHelper.retry(
///   () => someFirebaseCall(),
///   maxAttempts: 3,
/// );
/// ```
class RetryHelper {
  /// Executes [operation] with exponential backoff on failure.
  ///
  /// - [maxAttempts]: total number of attempts (default 3).
  /// - [initialDelay]: delay before the first retry (default 1 second).
  /// - [maxDelay]: cap on the delay between retries (default 30 seconds).
  /// - [retryIf]: optional predicate; only retries when this returns true.
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Object error)? retryIf,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e, st) {
        attempt++;
        final shouldRetry = retryIf == null || retryIf(e);
        if (attempt >= maxAttempts || !shouldRetry) {
          AppLogger.error(
            'RetryHelper: operation failed after $attempt attempt(s)',
            e,
            st,
          );
          rethrow;
        }
        final delay = _computeDelay(attempt, initialDelay, maxDelay);
        AppLogger.warning(
          'RetryHelper: attempt $attempt failed, retrying in ${delay.inMilliseconds}ms',
          e,
        );
        await Future.delayed(delay);
      }
    }
  }

  /// Computes exponential backoff delay with jitter.
  static Duration _computeDelay(
    int attempt,
    Duration initialDelay,
    Duration maxDelay,
  ) {
    final exponential = initialDelay * pow(2, attempt - 1).toInt();
    final capped = exponential > maxDelay ? maxDelay : exponential;
    // Add up to 20% jitter to avoid thundering herd
    final jitter = Duration(
      milliseconds: Random().nextInt((capped.inMilliseconds * 0.2).ceil() + 1),
    );
    return capped + jitter;
  }
}
