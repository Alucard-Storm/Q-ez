// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.teacher: 'teacher',
  UserRole.admin: 'admin',
};

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      level: (json['level'] as num).toInt(),
      badgeIds:
          (json['badgeIds'] as List<dynamic>).map((e) => e as String).toList(),
      totalQuizzesTaken: (json['totalQuizzesTaken'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
      'level': instance.level,
      'badgeIds': instance.badgeIds,
      'totalQuizzesTaken': instance.totalQuizzesTaken,
      'averageScore': instance.averageScore,
    };

_$TeacherImpl _$$TeacherImplFromJson(Map<String, dynamic> json) =>
    _$TeacherImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      createdQuizIds: (json['createdQuizIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$TeacherImplToJson(_$TeacherImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
      'createdQuizIds': instance.createdQuizIds,
    };

_$AdminImpl _$$AdminImplFromJson(Map<String, dynamic> json) => _$AdminImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      auditLogIds: (json['auditLogIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$AdminImplToJson(_$AdminImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
      'auditLogIds': instance.auditLogIds,
    };
