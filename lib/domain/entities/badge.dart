import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

enum BadgeType {
  quizzesCompleted,
  perfectScore,
  levelReached,
}

@freezed
class Badge with _$Badge {
  const Badge._();

  const factory Badge({
    required String id,
    required String name,
    required String description,
    required String iconAsset,
    required BadgeType type,
    required int requirement,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

  /// Returns a human-readable description of the unlock criteria
  String get unlockCriteria {
    switch (type) {
      case BadgeType.quizzesCompleted:
        return 'Complete $requirement ${requirement == 1 ? 'quiz' : 'quizzes'}';
      case BadgeType.perfectScore:
        return 'Achieve $requirement perfect ${requirement == 1 ? 'score' : 'scores'}';
      case BadgeType.levelReached:
        return 'Reach level $requirement';
    }
  }
}
