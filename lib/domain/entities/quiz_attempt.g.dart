// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityViolationImpl _$$SecurityViolationImplFromJson(
        Map<String, dynamic> json) =>
    _$SecurityViolationImpl(
      type: $enumDecode(_$SecurityViolationTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$SecurityViolationImplToJson(
        _$SecurityViolationImpl instance) =>
    <String, dynamic>{
      'type': _$SecurityViolationTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$SecurityViolationTypeEnumMap = {
  SecurityViolationType.tabSwitch: 'tabSwitch',
  SecurityViolationType.appSwitch: 'appSwitch',
  SecurityViolationType.copyAttempt: 'copyAttempt',
};

_$QuizAttemptImpl _$$QuizAttemptImplFromJson(Map<String, dynamic> json) =>
    _$QuizAttemptImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      quizId: json['quizId'] as String,
      answers: Map<String, int>.from(json['answers'] as Map),
      score: (json['score'] as num).toDouble(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      securityViolations: (json['securityViolations'] as num?)?.toInt() ?? 0,
      violations: (json['violations'] as List<dynamic>?)
              ?.map(
                  (e) => SecurityViolation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isFlagged: json['isFlagged'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuizAttemptImplToJson(_$QuizAttemptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'quizId': instance.quizId,
      'answers': instance.answers,
      'score': instance.score,
      'totalQuestions': instance.totalQuestions,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'securityViolations': instance.securityViolations,
      'violations': instance.violations,
      'isFlagged': instance.isFlagged,
    };
