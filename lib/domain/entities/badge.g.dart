// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconAsset: json['iconAsset'] as String,
      type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
      requirement: (json['requirement'] as num).toInt(),
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconAsset': instance.iconAsset,
      'type': _$BadgeTypeEnumMap[instance.type]!,
      'requirement': instance.requirement,
    };

const _$BadgeTypeEnumMap = {
  BadgeType.quizzesCompleted: 'quizzesCompleted',
  BadgeType.perfectScore: 'perfectScore',
  BadgeType.levelReached: 'levelReached',
};
