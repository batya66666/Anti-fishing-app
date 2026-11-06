// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionRequest _$ActionRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActionRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['scenarioId', 'action']);
      final val = ActionRequest(
        scenarioId: $checkedConvert('scenarioId', (v) => v as String),
        action: $checkedConvert('action', (v) => v as String),
        ms: $checkedConvert('ms', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ActionRequestToJson(ActionRequest instance) =>
    <String, dynamic>{
      'scenarioId': instance.scenarioId,
      'action': instance.action,
      'ms': ?instance.ms,
    };
