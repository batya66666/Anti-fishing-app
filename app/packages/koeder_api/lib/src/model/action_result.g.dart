// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionResult _$ActionResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActionResult', json, ($checkedConvert) {
      final val = ActionResult(
        evaluation: $checkedConvert(
          'evaluation',
          (v) =>
              v == null ? null : Evaluation.fromJson(v as Map<String, dynamic>),
        ),
        answered: $checkedConvert('answered', (v) => (v as num?)?.toInt()),
        total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
        shiftCompleted: $checkedConvert('shiftCompleted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$ActionResultToJson(ActionResult instance) =>
    <String, dynamic>{
      'evaluation': ?instance.evaluation?.toJson(),
      'answered': ?instance.answered,
      'total': ?instance.total,
      'shiftCompleted': ?instance.shiftCompleted,
    };
