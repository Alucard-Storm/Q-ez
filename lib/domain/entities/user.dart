import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  student,
  teacher,
  admin,
}

/// Abstract base for all user types.
/// Provides common fields shared by User, Student, Teacher, and Admin.
abstract class AppUser {
  String get id;
  String get email;
  String get name;
  UserRole get role;
  DateTime get createdAt;
  DateTime get lastLoginAt;
}

@freezed
class User with _$User implements AppUser {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Student with _$Student implements AppUser {
  const factory Student({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    required int level,
    required List<String> badgeIds,
    required int totalQuizzesTaken,
    required double averageScore,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}

@freezed
class Teacher with _$Teacher implements AppUser {
  const factory Teacher({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    required List<String> createdQuizIds,
  }) = _Teacher;

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);
}

@freezed
class Admin with _$Admin implements AppUser {
  const factory Admin({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    required List<String> auditLogIds,
  }) = _Admin;

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
}
