import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/connectivity_service.dart';

/// Provider for the [ConnectivityService] singleton.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// StreamProvider that emits `true` when online and `false` when offline.
///
/// Defaults to `true` (online) while the initial check is in progress.
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);

  // Emit the current status first
  final current = await service.isOnline();
  yield current;

  // Then emit changes
  yield* service.onConnectivityChanged;
});

/// Convenience provider that returns `true` when the device is online.
///
/// Reads the latest value from [connectivityStreamProvider]; defaults to
/// `true` so the UI doesn't flash "offline" on startup.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).valueOrNull ?? true;
});
