// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayShift _$TodayShiftFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TodayShift', json, ($checkedConvert) {
      final val = TodayShift(
        id: $checkedConvert('id', (v) => v as String?),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        completed: $checkedConvert('completed', (v) => v as bool?),
        score: $checkedConvert('score', (v) => (v as num?)?.toInt()),
        scenarios: $checkedConvert(
          'scenarios',
          (v) => (v as List<dynamic>?)
              ?.map((e) => PublicScenario.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        answered: $checkedConvert(
          'answered',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TodayShiftToJson(TodayShift instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'date': ?instance.date?.toIso8601String(),
      'completed': ?instance.completed,
      'score': ?instance.score,
      'scenarios': ?instance.scenarios?.map((e) => e.toJson()).toList(),
      'answered': ?instance.answered,
    };
