// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scenario _$ScenarioFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Scenario',
  json,
  ($checkedConvert) {
    final val = Scenario(
      id: $checkedConvert('id', (v) => v as String?),
      type: $checkedConvert('type', (v) => v as String?),
      locale: $checkedConvert('locale', (v) => v as String?),
      difficulty: $checkedConvert('difficulty', (v) => v as String?),
      isAttack: $checkedConvert('is_attack', (v) => v as bool?),
      attackType: $checkedConvert('attack_type', (v) => v as String?),
      module: $checkedConvert('module', (v) => (v as num?)?.toInt()),
      consumer: $checkedConvert('consumer', (v) => v as bool?),
      content: $checkedConvert(
        'content',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      redFlags: $checkedConvert(
        'red_flags',
        (v) => (v as List<dynamic>?)
            ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      correctActions: $checkedConvert(
        'correct_actions',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      dangerousActions: $checkedConvert(
        'dangerous_actions',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      explanation: $checkedConvert('explanation', (v) => v as String?),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      orgId: $checkedConvert('orgId', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'isAttack': 'is_attack',
    'attackType': 'attack_type',
    'redFlags': 'red_flags',
    'correctActions': 'correct_actions',
    'dangerousActions': 'dangerous_actions',
  },
);

Map<String, dynamic> _$ScenarioToJson(Scenario instance) => <String, dynamic>{
  'id': ?instance.id,
  'type': ?instance.type,
  'locale': ?instance.locale,
  'difficulty': ?instance.difficulty,
  'is_attack': ?instance.isAttack,
  'attack_type': ?instance.attackType,
  'module': ?instance.module,
  'consumer': ?instance.consumer,
  'content': ?instance.content,
  'red_flags': ?instance.redFlags?.map((e) => e.toJson()).toList(),
  'correct_actions': ?instance.correctActions,
  'dangerous_actions': ?instance.dangerousActions,
  'explanation': ?instance.explanation,
  'tags': ?instance.tags,
  'orgId': ?instance.orgId,
};
