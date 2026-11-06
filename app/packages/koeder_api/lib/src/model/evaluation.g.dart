// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Evaluation _$EvaluationFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Evaluation',
  json,
  ($checkedConvert) {
    final val = Evaluation(
      outcome: $checkedConvert(
        'outcome',
        (v) => $enumDecodeNullable(_$EvaluationOutcomeEnumEnumMap, v),
      ),
      correct: $checkedConvert('correct', (v) => v as bool?),
      attack: $checkedConvert('attack', (v) => v as bool?),
      reported: $checkedConvert('reported', (v) => v as bool?),
      points: $checkedConvert('points', (v) => (v as num?)?.toInt()),
      xp: $checkedConvert('xp', (v) => (v as num?)?.toInt()),
      coins: $checkedConvert('coins', (v) => (v as num?)?.toInt()),
      flagsFound: $checkedConvert('flagsFound', (v) => (v as num?)?.toInt()),
      flagsMissed: $checkedConvert('flagsMissed', (v) => (v as num?)?.toInt()),
      flagsWrong: $checkedConvert('flagsWrong', (v) => (v as num?)?.toInt()),
      redFlags: $checkedConvert(
        'redFlags',
        (v) => (v as List<dynamic>?)
            ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      attackType: $checkedConvert('attackType', (v) => v as String?),
      explanation: $checkedConvert('explanation', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$EvaluationToJson(Evaluation instance) =>
    <String, dynamic>{
      'outcome': ?_$EvaluationOutcomeEnumEnumMap[instance.outcome],
      'correct': ?instance.correct,
      'attack': ?instance.attack,
      'reported': ?instance.reported,
      'points': ?instance.points,
      'xp': ?instance.xp,
      'coins': ?instance.coins,
      'flagsFound': ?instance.flagsFound,
      'flagsMissed': ?instance.flagsMissed,
      'flagsWrong': ?instance.flagsWrong,
      'redFlags': ?instance.redFlags?.map((e) => e.toJson()).toList(),
      'attackType': ?instance.attackType,
      'explanation': ?instance.explanation,
    };

const _$EvaluationOutcomeEnumEnumMap = {
  EvaluationOutcomeEnum.CORRECT: 'CORRECT',
  EvaluationOutcomeEnum.SAFE: 'SAFE',
  EvaluationOutcomeEnum.HACKED: 'HACKED',
  EvaluationOutcomeEnum.FALSE_ALARM: 'FALSE_ALARM',
  EvaluationOutcomeEnum.MISSED: 'MISSED',
};
