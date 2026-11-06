// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => $checkedCreate(
  'JoinRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['code']);
    final val = JoinRequest(code: $checkedConvert('code', (v) => v as String));
    return val;
  },
);

Map<String, dynamic> _$JoinRequestToJson(JoinRequest instance) =>
    <String, dynamic>{'code': instance.code};
