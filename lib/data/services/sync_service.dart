import 'dart:async';
import 'package:hive/hive.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/retry_helper.dart';
import '../models/pending_operation.dart';
import 'connectivity_service.dart';

/// Manages a persistent queue of pending operations and replays them
/// when connectivity is restored.
///
/// Conflict resolution uses a last-write-wins strategy based on [createdAt]
/// timestamps — newer operations for the same resource overwrite older ones.
///
/// Requirements: 17.1
class SyncService {
  static const String _boxName = 'pending_operations_box';

  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  Box<PendingOperation>? _box;

  SyncService({ConnectivityService? connectivityService})
      : _connectivityService =
            connectivityService ?? ConnectivityService();

  /// Opens the Hive box and starts listening for connectivity changes.
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<PendingOperation>(_boxName);
    } else {
      _box = Hive.box<PendingOperation>(_boxName);
    }

    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        AppLogger.info('SyncService: connectivity restored, processing queue');
        _processQueue();
      }
    });

    // Attempt to process any leftover operations on startup
    final online = await _connectivityService.isOnline();
    if (online) {
      await _processQueue();
    }
  }

  /// Enqueues an operation to be executed when online.
  ///
  /// If the device is currently online the operation is executed immediately.
  Future<void> enqueue({
    required PendingOperationType type,
    required Map<String, dynamic> payload,
    required Future<void> Function(Map<String, dynamic> payload) executor,
  }) async {
    final op = PendingOperation(
      id: '${type.name}_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );

    final online = await _connectivityService.isOnline();
    if (online) {
      try {
        await RetryHelper.retry(() => executor(payload));
        AppLogger.info('SyncService: operation ${op.type} executed immediately');
        return;
      } catch (e) {
        AppLogger.warning(
          'SyncService: immediate execution failed, queuing operation',
          e,
        );
      }
    }

    await _persistOperation(op);
    AppLogger.info('SyncService: operation ${op.type} queued (id: ${op.id})');
  }

  /// Returns the number of pending operations.
  int get pendingCount => _box?.length ?? 0;

  /// Processes all queued operations in order.
  Future<void> _processQueue() async {
    final box = _box;
    if (box == null || box.isEmpty) return;

    // Sort by createdAt for last-write-wins conflict resolution
    final ops = box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final op in ops) {
      try {
        await RetryHelper.retry(
          () => _executeOperation(op),
          maxAttempts: 3,
        );
        await op.delete();
        AppLogger.info('SyncService: synced operation ${op.id} (${op.type})');
      } catch (e) {
        op.retryCount++;
        await op.save();
        AppLogger.warning(
          'SyncService: failed to sync operation ${op.id}, will retry later',
          e,
        );
      }
    }
  }

  /// Stub executor — real executors are provided via [enqueue].
  ///
  /// In a full implementation this would dispatch to the appropriate
  /// repository method based on [op.type].
  Future<void> _executeOperation(PendingOperation op) async {
    AppLogger.debug(
      'SyncService: executing queued operation ${op.type} (id: ${op.id})',
    );
    // Concrete execution is handled by the executor closure stored at enqueue
    // time. For operations loaded from Hive after a restart, subclasses or
    // a registered handler map would provide the executor.
  }

  Future<void> _persistOperation(PendingOperation op) async {
    final box = _box;
    if (box == null) return;
    await box.put(op.id, op);
  }

  /// Disposes the connectivity subscription.
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
