// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'red_flag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedFlag _$RedFlagFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RedFlag', json, ($checkedConvert) {
      final val = RedFlag(
        target: $checkedConvert('target', (v) => v as String?),
        hint: $checkedConvert('hint', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RedFlagToJson(RedFlag instance) => <String, dynamic>{
  'target': ?instance.target,
  'hint': ?instance.hint,
};
