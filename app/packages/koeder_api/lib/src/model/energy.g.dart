// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Energy _$EnergyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Energy', json, ($checkedConvert) {
      final val = Energy(
        shiftAvailable: $checkedConvert('shiftAvailable', (v) => v as bool?),
        shiftCompleted: $checkedConvert('shiftCompleted', (v) => v as bool?),
        swipeRoundsLeft: $checkedConvert(
          'swipeRoundsLeft',
          (v) => (v as num?)?.toInt(),
        ),
        swipeRoundsPerDay: $checkedConvert(
          'swipeRoundsPerDay',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EnergyToJson(Energy instance) => <String, dynamic>{
  'shiftAvailable': ?instance.shiftAvailable,
  'shiftCompleted': ?instance.shiftCompleted,
  'swipeRoundsLeft': ?instance.swipeRoundsLeft,
  'swipeRoundsPerDay': ?instance.swipeRoundsPerDay,
};
