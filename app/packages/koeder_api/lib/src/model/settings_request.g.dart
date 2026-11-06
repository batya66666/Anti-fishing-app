// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsRequest _$SettingsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SettingsRequest', json, ($checkedConvert) {
      final val = SettingsRequest(
        displayName: $checkedConvert('displayName', (v) => v as String?),
        avatar: $checkedConvert('avatar', (v) => (v as num?)?.toInt()),
        locale: $checkedConvert('locale', (v) => v as String?),
        mode: $checkedConvert('mode', (v) => v as String?),
        publicBoard: $checkedConvert('publicBoard', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$SettingsRequestToJson(SettingsRequest instance) =>
    <String, dynamic>{
      'displayName': ?instance.displayName,
      'avatar': ?instance.avatar,
      'locale': ?instance.locale,
      'mode': ?instance.mode,
      'publicBoard': ?instance.publicBoard,
    };
