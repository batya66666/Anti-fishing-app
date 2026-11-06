// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeResponse _$CodeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeResponse', json, ($checkedConvert) {
      final val = CodeResponse(
        code: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CodeResponseToJson(CodeResponse instance) =>
    <String, dynamic>{'code': ?instance.code};
