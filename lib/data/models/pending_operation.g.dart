// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingOperationAdapter extends TypeAdapter<PendingOperation> {
  @override
  final int typeId = 5;

  @override
  PendingOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingOperation(
      id: fields[0] as String,
      type: fields[1] as PendingOperationType,
      payload: (fields[2] as Map).cast<String, dynamic>(),
      createdAt: fields[3] as DateTime,
      retryCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingOperation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PendingOperationTypeAdapter extends TypeAdapter<PendingOperationType> {
  @override
  final int typeId = 4;

  @override
  PendingOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PendingOperationType.submitAnswer;
      case 1:
        return PendingOperationType.completeQuizAttempt;
      case 2:
        return PendingOperationType.recordViolation;
      default:
        return PendingOperationType.submitAnswer;
    }
  }

  @override
  void write(BinaryWriter writer, PendingOperationType obj) {
    switch (obj) {
      case PendingOperationType.submitAnswer:
        writer.writeByte(0);
        break;
      case PendingOperationType.completeQuizAttempt:
        writer.writeByte(1);
        break;
      case PendingOperationType.recordViolation:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
