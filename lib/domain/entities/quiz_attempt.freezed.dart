// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_attempt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecurityViolation _$SecurityViolationFromJson(Map<String, dynamic> json) {
  return _SecurityViolation.fromJson(json);
}

/// @nodoc
mixin _$SecurityViolation {
  SecurityViolationType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this SecurityViolation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityViolation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityViolationCopyWith<SecurityViolation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityViolationCopyWith<$Res> {
  factory $SecurityViolationCopyWith(
          SecurityViolation value, $Res Function(SecurityViolation) then) =
      _$SecurityViolationCopyWithImpl<$Res, SecurityViolation>;
  @useResult
  $Res call({SecurityViolationType type, DateTime timestamp});
}

/// @nodoc
class _$SecurityViolationCopyWithImpl<$Res, $Val extends SecurityViolation>
    implements $SecurityViolationCopyWith<$Res> {
  _$SecurityViolationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityViolation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityViolationType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityViolationImplCopyWith<$Res>
    implements $SecurityViolationCopyWith<$Res> {
  factory _$$SecurityViolationImplCopyWith(_$SecurityViolationImpl value,
          $Res Function(_$SecurityViolationImpl) then) =
      __$$SecurityViolationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SecurityViolationType type, DateTime timestamp});
}

/// @nodoc
class __$$SecurityViolationImplCopyWithImpl<$Res>
    extends _$SecurityViolationCopyWithImpl<$Res, _$SecurityViolationImpl>
    implements _$$SecurityViolationImplCopyWith<$Res> {
  __$$SecurityViolationImplCopyWithImpl(_$SecurityViolationImpl _value,
      $Res Function(_$SecurityViolationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityViolation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(_$SecurityViolationImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityViolationType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityViolationImpl implements _SecurityViolation {
  const _$SecurityViolationImpl({required this.type, required this.timestamp});

  factory _$SecurityViolationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityViolationImplFromJson(json);

  @override
  final SecurityViolationType type;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SecurityViolation(type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityViolationImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, timestamp);

  /// Create a copy of SecurityViolation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityViolationImplCopyWith<_$SecurityViolationImpl> get copyWith =>
      __$$SecurityViolationImplCopyWithImpl<_$SecurityViolationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityViolationImplToJson(
      this,
    );
  }
}

abstract class _SecurityViolation implements SecurityViolation {
  const factory _SecurityViolation(
      {required final SecurityViolationType type,
      required final DateTime timestamp}) = _$SecurityViolationImpl;

  factory _SecurityViolation.fromJson(Map<String, dynamic> json) =
      _$SecurityViolationImpl.fromJson;

  @override
  SecurityViolationType get type;
  @override
  DateTime get timestamp;

  /// Create a copy of SecurityViolation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityViolationImplCopyWith<_$SecurityViolationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizAttempt _$QuizAttemptFromJson(Map<String, dynamic> json) {
  return _QuizAttempt.fromJson(json);
}

/// @nodoc
mixin _$QuizAttempt {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get quizId => throw _privateConstructorUsedError;
  Map<String, int> get answers => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get securityViolations => throw _privateConstructorUsedError;
  List<SecurityViolation> get violations => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;

  /// Serializes this QuizAttempt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuizAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizAttemptCopyWith<QuizAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizAttemptCopyWith<$Res> {
  factory $QuizAttemptCopyWith(
          QuizAttempt value, $Res Function(QuizAttempt) then) =
      _$QuizAttemptCopyWithImpl<$Res, QuizAttempt>;
  @useResult
  $Res call(
      {String id,
      String studentId,
      String quizId,
      Map<String, int> answers,
      double score,
      int totalQuestions,
      DateTime startedAt,
      DateTime? completedAt,
      int securityViolations,
      List<SecurityViolation> violations,
      bool isFlagged});
}

/// @nodoc
class _$QuizAttemptCopyWithImpl<$Res, $Val extends QuizAttempt>
    implements $QuizAttemptCopyWith<$Res> {
  _$QuizAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? quizId = null,
    Object? answers = null,
    Object? score = null,
    Object? totalQuestions = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? securityViolations = null,
    Object? violations = null,
    Object? isFlagged = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      securityViolations: null == securityViolations
          ? _value.securityViolations
          : securityViolations // ignore: cast_nullable_to_non_nullable
              as int,
      violations: null == violations
          ? _value.violations
          : violations // ignore: cast_nullable_to_non_nullable
              as List<SecurityViolation>,
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizAttemptImplCopyWith<$Res>
    implements $QuizAttemptCopyWith<$Res> {
  factory _$$QuizAttemptImplCopyWith(
          _$QuizAttemptImpl value, $Res Function(_$QuizAttemptImpl) then) =
      __$$QuizAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String studentId,
      String quizId,
      Map<String, int> answers,
      double score,
      int totalQuestions,
      DateTime startedAt,
      DateTime? completedAt,
      int securityViolations,
      List<SecurityViolation> violations,
      bool isFlagged});
}

/// @nodoc
class __$$QuizAttemptImplCopyWithImpl<$Res>
    extends _$QuizAttemptCopyWithImpl<$Res, _$QuizAttemptImpl>
    implements _$$QuizAttemptImplCopyWith<$Res> {
  __$$QuizAttemptImplCopyWithImpl(
      _$QuizAttemptImpl _value, $Res Function(_$QuizAttemptImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuizAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? quizId = null,
    Object? answers = null,
    Object? score = null,
    Object? totalQuestions = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? securityViolations = null,
    Object? violations = null,
    Object? isFlagged = null,
  }) {
    return _then(_$QuizAttemptImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      securityViolations: null == securityViolations
          ? _value.securityViolations
          : securityViolations // ignore: cast_nullable_to_non_nullable
              as int,
      violations: null == violations
          ? _value._violations
          : violations // ignore: cast_nullable_to_non_nullable
              as List<SecurityViolation>,
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizAttemptImpl extends _QuizAttempt {
  const _$QuizAttemptImpl(
      {required this.id,
      required this.studentId,
      required this.quizId,
      required final Map<String, int> answers,
      required this.score,
      required this.totalQuestions,
      required this.startedAt,
      this.completedAt,
      this.securityViolations = 0,
      final List<SecurityViolation> violations = const [],
      this.isFlagged = false})
      : _answers = answers,
        _violations = violations,
        super._();

  factory _$QuizAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizAttemptImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String quizId;
  final Map<String, int> _answers;
  @override
  Map<String, int> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  final double score;
  @override
  final int totalQuestions;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int securityViolations;
  final List<SecurityViolation> _violations;
  @override
  @JsonKey()
  List<SecurityViolation> get violations {
    if (_violations is EqualUnmodifiableListView) return _violations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_violations);
  }

  @override
  @JsonKey()
  final bool isFlagged;

  @override
  String toString() {
    return 'QuizAttempt(id: $id, studentId: $studentId, quizId: $quizId, answers: $answers, score: $score, totalQuestions: $totalQuestions, startedAt: $startedAt, completedAt: $completedAt, securityViolations: $securityViolations, violations: $violations, isFlagged: $isFlagged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizAttemptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.securityViolations, securityViolations) ||
                other.securityViolations == securityViolations) &&
            const DeepCollectionEquality()
                .equals(other._violations, _violations) &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      studentId,
      quizId,
      const DeepCollectionEquality().hash(_answers),
      score,
      totalQuestions,
      startedAt,
      completedAt,
      securityViolations,
      const DeepCollectionEquality().hash(_violations),
      isFlagged);

  /// Create a copy of QuizAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizAttemptImplCopyWith<_$QuizAttemptImpl> get copyWith =>
      __$$QuizAttemptImplCopyWithImpl<_$QuizAttemptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizAttemptImplToJson(
      this,
    );
  }
}

abstract class _QuizAttempt extends QuizAttempt {
  const factory _QuizAttempt(
      {required final String id,
      required final String studentId,
      required final String quizId,
      required final Map<String, int> answers,
      required final double score,
      required final int totalQuestions,
      required final DateTime startedAt,
      final DateTime? completedAt,
      final int securityViolations,
      final List<SecurityViolation> violations,
      final bool isFlagged}) = _$QuizAttemptImpl;
  const _QuizAttempt._() : super._();

  factory _QuizAttempt.fromJson(Map<String, dynamic> json) =
      _$QuizAttemptImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get quizId;
  @override
  Map<String, int> get answers;
  @override
  double get score;
  @override
  int get totalQuestions;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  int get securityViolations;
  @override
  List<SecurityViolation> get violations;
  @override
  bool get isFlagged;

  /// Create a copy of QuizAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizAttemptImplCopyWith<_$QuizAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
