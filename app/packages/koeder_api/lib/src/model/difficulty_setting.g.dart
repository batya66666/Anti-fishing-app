// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultySetting _$DifficultySettingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DifficultySetting', json, ($checkedConvert) {
      final val = DifficultySetting(
        difficulty: $checkedConvert('difficulty', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DifficultySettingToJson(DifficultySetting instance) =>
    <String, dynamic>{'difficulty': ?instance.difficulty};
