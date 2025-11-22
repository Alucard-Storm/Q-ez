import 'package:hive/hive.dart';

part 'cached_quiz.g.dart';

@HiveType(typeId: 1)
class CachedQuestion extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  List<String> options;

  @HiveField(3)
  int correctOptionIndex;

  CachedQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}

@HiveType(typeId: 2)
class CachedQuiz extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String teacherId;

  @HiveField(4)
  String pin;

  @HiveField(5)
  int? timeLimitMinutes;

  @HiveField(6)
  List<CachedQuestion> questions;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isActive;

  CachedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.pin,
    this.timeLimitMinutes,
    required this.questions,
    required this.createdAt,
    required this.isActive,
  });
}
