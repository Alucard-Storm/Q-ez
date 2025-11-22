// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_quiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedQuestionAdapter extends TypeAdapter<CachedQuestion> {
  @override
  final int typeId = 1;

  @override
  CachedQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedQuestion(
      id: fields[0] as String,
      text: fields[1] as String,
      options: (fields[2] as List).cast<String>(),
      correctOptionIndex: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedQuestion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.correctOptionIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedQuizAdapter extends TypeAdapter<CachedQuiz> {
  @override
  final int typeId = 2;

  @override
  CachedQuiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedQuiz(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      teacherId: fields[3] as String,
      pin: fields[4] as String,
      timeLimitMinutes: fields[5] as int?,
      questions: (fields[6] as List).cast<CachedQuestion>(),
      createdAt: fields[7] as DateTime,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedQuiz obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.teacherId)
      ..writeByte(4)
      ..write(obj.pin)
      ..writeByte(5)
      ..write(obj.timeLimitMinutes)
      ..writeByte(6)
      ..write(obj.questions)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedQuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
