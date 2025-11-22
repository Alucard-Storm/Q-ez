// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedUserAdapter extends TypeAdapter<CachedUser> {
  @override
  final int typeId = 0;

  @override
  CachedUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUser(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as String,
      level: fields[4] as int?,
      badgeIds: (fields[5] as List?)?.cast<String>(),
      totalQuizzesTaken: fields[6] as int?,
      averageScore: fields[7] as double?,
      createdQuizIds: (fields[8] as List?)?.cast<String>(),
      auditLogIds: (fields[9] as List?)?.cast<String>(),
      createdAt: fields[10] as DateTime,
      lastLoginAt: fields[11] as DateTime,
      encryptedToken: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUser obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.badgeIds)
      ..writeByte(6)
      ..write(obj.totalQuizzesTaken)
      ..writeByte(7)
      ..write(obj.averageScore)
      ..writeByte(8)
      ..write(obj.createdQuizIds)
      ..writeByte(9)
      ..write(obj.auditLogIds)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastLoginAt)
      ..writeByte(12)
      ..write(obj.encryptedToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
