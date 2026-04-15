import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// A widget that catches errors in its subtree and displays a graceful fallback UI.
///
/// Wrap any widget subtree that might throw errors during build with this widget
/// to prevent the entire app from crashing.
///
/// Example:
/// ```dart
/// ErrorBoundary(
///   child: MyRiskyWidget(),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  /// Optional custom fallback widget. Defaults to [_DefaultErrorWidget].
  final Widget Function(Object error, StackTrace? stackTrace)? fallbackBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Override the error widget builder for this subtree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
          });
        }
      });
      AppLogger.error(
        'Widget build error caught by ErrorBoundary',
        details.exception,
        details.stack,
      );
      return const SizedBox.shrink();
    };
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(_error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _reset,
      );
    }
    return widget.child;
  }
}

/// Default fallback UI shown when an error is caught by [ErrorBoundary]
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'An unexpected error occurred. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
