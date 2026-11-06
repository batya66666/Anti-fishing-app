// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckRequest _$CheckRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CheckRequest', json, ($checkedConvert) {
      final val = CheckRequest(
        text: $checkedConvert('text', (v) => v as String?),
        imageBase64: $checkedConvert('imageBase64', (v) => v as String?),
        mediaType: $checkedConvert('mediaType', (v) => v as String?),
        locale: $checkedConvert('locale', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CheckRequestToJson(CheckRequest instance) =>
    <String, dynamic>{
      'text': ?instance.text,
      'imageBase64': ?instance.imageBase64,
      'mediaType': ?instance.mediaType,
      'locale': ?instance.locale,
    };
