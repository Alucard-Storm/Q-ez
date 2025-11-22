// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecuritySettingsAdapter extends TypeAdapter<SecuritySettings> {
  @override
  final int typeId = 3;

  @override
  SecuritySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecuritySettings(
      biometricEnabled: fields[0] as bool,
      maxViolations: fields[1] as int,
      strictMode: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SecuritySettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.biometricEnabled)
      ..writeByte(1)
      ..write(obj.maxViolations)
      ..writeByte(2)
      ..write(obj.strictMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecuritySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
