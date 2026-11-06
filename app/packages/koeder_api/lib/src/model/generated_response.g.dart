// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedResponse _$GeneratedResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GeneratedResponse', json, ($checkedConvert) {
      final val = GeneratedResponse(
        scenarios: $checkedConvert(
          'scenarios',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Scenario.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        source_: $checkedConvert('source', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$GeneratedResponseToJson(GeneratedResponse instance) =>
    <String, dynamic>{
      'scenarios': ?instance.scenarios?.map((e) => e.toJson()).toList(),
      'source': ?instance.source_,
    };
