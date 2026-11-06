// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duel_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuelRef _$DuelRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DuelRef',
  json,
  ($checkedConvert) {
    final val = DuelRef(duelId: $checkedConvert('duelId', (v) => v as String?));
    return val;
  },
);

Map<String, dynamic> _$DuelRefToJson(DuelRef instance) => <String, dynamic>{
  'duelId': ?instance.duelId,
};
