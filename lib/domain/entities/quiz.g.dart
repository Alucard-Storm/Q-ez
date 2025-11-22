// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctOptionIndex: (json['correctOptionIndex'] as num).toInt(),
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'options': instance.options,
      'correctOptionIndex': instance.correctOptionIndex,
    };

_$QuizImpl _$$QuizImplFromJson(Map<String, dynamic> json) => _$QuizImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      teacherId: json['teacherId'] as String,
      pin: json['pin'] as String,
      timeLimitMinutes: (json['timeLimitMinutes'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$QuizImplToJson(_$QuizImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'teacherId': instance.teacherId,
      'pin': instance.pin,
      'timeLimitMinutes': instance.timeLimitMinutes,
      'questions': instance.questions,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };
