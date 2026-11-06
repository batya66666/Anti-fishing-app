// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestRequest _$GuestRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GuestRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deviceId']);
      final val = GuestRequest(
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        displayName: $checkedConvert('displayName', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GuestRequestToJson(GuestRequest instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'displayName': ?instance.displayName,
      'locale': ?instance.locale,
    };
