// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeRequest _$PracticeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PracticeRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['scenarioId']);
      final val = PracticeRequest(
        scenarioId: $checkedConvert('scenarioId', (v) => v as String),
        context: $checkedConvert('context', (v) => v as String?),
        action: $checkedConvert('action', (v) => v as String?),
        flags: $checkedConvert(
          'flags',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        ms: $checkedConvert('ms', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$PracticeRequestToJson(PracticeRequest instance) =>
    <String, dynamic>{
      'scenarioId': instance.scenarioId,
      'context': ?instance.context,
      'action': ?instance.action,
      'flags': ?instance.flags,
      'ms': ?instance.ms,
    };
