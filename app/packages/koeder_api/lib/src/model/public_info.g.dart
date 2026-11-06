// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicInfo _$PublicInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicInfo', json, ($checkedConvert) {
      final val = PublicInfo(
        publicUrl: $checkedConvert('publicUrl', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PublicInfoToJson(PublicInfo instance) =>
    <String, dynamic>{'publicUrl': ?instance.publicUrl};
