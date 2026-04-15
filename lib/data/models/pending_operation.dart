import 'package:hive/hive.dart';

part 'pending_operation.g.dart';

/// Types of operations that can be queued for background sync.
@HiveType(typeId: 4)
enum PendingOperationType {
  @HiveField(0)
  submitAnswer,

  @HiveField(1)
  completeQuizAttempt,

  @HiveField(2)
  recordViolation,
}

/// A pending operation stored locally when the device is offline.
///
/// Operations are persisted in Hive and replayed when connectivity is restored.
@HiveType(typeId: 5)
class PendingOperation extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  PendingOperationType type;

  /// JSON-encoded payload for the operation.
  @HiveField(2)
  Map<String, dynamic> payload;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });
}
