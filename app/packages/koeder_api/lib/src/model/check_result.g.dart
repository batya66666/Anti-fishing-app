// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckResult _$CheckResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CheckResult', json, ($checkedConvert) {
      final val = CheckResult(
        verdict: $checkedConvert('verdict', (v) => v as String?),
        riskScore: $checkedConvert('riskScore', (v) => (v as num?)?.toInt()),
        findings: $checkedConvert(
          'findings',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Finding.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        recommendation: $checkedConvert('recommendation', (v) => v as String?),
        source_: $checkedConvert('source', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$CheckResultToJson(CheckResult instance) =>
    <String, dynamic>{
      'verdict': ?instance.verdict,
      'riskScore': ?instance.riskScore,
      'findings': ?instance.findings?.map((e) => e.toJson()).toList(),
      'recommendation': ?instance.recommendation,
      'source': ?instance.source_,
    };
