import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class that delays the execution of a callback until after
/// a specified duration has elapsed since the last call.
///
/// Useful for search inputs to avoid firing queries on every keystroke.
///
/// Example:
/// ```dart
/// final _debouncer = Debouncer(delay: Duration(milliseconds: 400));
///
/// void onSearchChanged(String query) {
///   _debouncer.run(() => _performSearch(query));
/// }
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  /// Schedules [action] to run after [delay]. If called again before
  /// the delay expires, the previous scheduled call is cancelled.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending scheduled action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether there is a pending scheduled action.
  bool get isPending => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
  }
}
