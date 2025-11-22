import 'package:hive/hive.dart';

part 'cached_user.g.dart';

@HiveType(typeId: 0)
class CachedUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  String role;

  @HiveField(4)
  int? level;

  @HiveField(5)
  List<String>? badgeIds;

  @HiveField(6)
  int? totalQuizzesTaken;

  @HiveField(7)
  double? averageScore;

  @HiveField(8)
  List<String>? createdQuizIds;

  @HiveField(9)
  List<String>? auditLogIds;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime lastLoginAt;

  @HiveField(12)
  String? encryptedToken;

  CachedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.level,
    this.badgeIds,
    this.totalQuizzesTaken,
    this.averageScore,
    this.createdQuizIds,
    this.auditLogIds,
    required this.createdAt,
    required this.lastLoginAt,
    this.encryptedToken,
  });
}
