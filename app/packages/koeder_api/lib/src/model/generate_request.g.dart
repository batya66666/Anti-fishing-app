// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateRequest _$GenerateRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GenerateRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['companyName']);
      final val = GenerateRequest(
        companyName: $checkedConvert('companyName', (v) => v as String),
        industry: $checkedConvert('industry', (v) => v as String?),
        tools: $checkedConvert('tools', (v) => v as String?),
        partners: $checkedConvert('partners', (v) => v as String?),
        employees: $checkedConvert('employees', (v) => (v as num?)?.toInt()),
        count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
        locale: $checkedConvert('locale', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GenerateRequestToJson(GenerateRequest instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'industry': ?instance.industry,
      'tools': ?instance.tools,
      'partners': ?instance.partners,
      'employees': ?instance.employees,
      'count': ?instance.count,
      'locale': ?instance.locale,
    };
