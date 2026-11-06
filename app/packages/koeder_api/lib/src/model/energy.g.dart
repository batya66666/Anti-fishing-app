// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Energy _$EnergyFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Energy',
  json,
  ($checkedConvert) {
    final val = Energy(
      shiftCompleted: $checkedConvert('shiftCompleted', (v) => v as bool?),
      shiftsToday: $checkedConvert('shiftsToday', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$EnergyToJson(Energy instance) => <String, dynamic>{
  'shiftCompleted': ?instance.shiftCompleted,
  'shiftsToday': ?instance.shiftsToday,
};
