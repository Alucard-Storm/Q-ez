import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/app_logger.dart';

/// Monitors network connectivity and exposes a reactive stream.
///
/// Requirements: 17.1
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity status changes.
  ///
  /// Emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((result) => result != ConnectivityResult.none);
  }

  /// Returns the current connectivity status synchronously (async check).
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      AppLogger.warning('ConnectivityService: failed to check connectivity', e);
      return true; // assume online on error to avoid blocking operations
    }
  }
}
