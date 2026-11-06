// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicScenario _$PublicScenarioFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicScenario', json, ($checkedConvert) {
      final val = PublicScenario(
        id: $checkedConvert('id', (v) => v as String?),
        type: $checkedConvert('type', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
        difficulty: $checkedConvert('difficulty', (v) => v as String?),
        module: $checkedConvert('module', (v) => (v as num?)?.toInt()),
        content: $checkedConvert(
          'content',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PublicScenarioToJson(PublicScenario instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'type': ?instance.type,
      'locale': ?instance.locale,
      'difficulty': ?instance.difficulty,
      'module': ?instance.module,
      'content': ?instance.content,
    };
