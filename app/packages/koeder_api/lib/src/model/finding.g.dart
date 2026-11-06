// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Finding _$FindingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Finding', json, ($checkedConvert) {
      final val = Finding(
        title: $checkedConvert('title', (v) => v as String?),
        detail: $checkedConvert('detail', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$FindingToJson(Finding instance) => <String, dynamic>{
  'title': ?instance.title,
  'detail': ?instance.detail,
};
