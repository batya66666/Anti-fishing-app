// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardRow _$BoardRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BoardRow', json, ($checkedConvert) {
      final val = BoardRow(
        rank: $checkedConvert('rank', (v) => (v as num?)?.toInt()),
        userId: $checkedConvert('userId', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        avatar: $checkedConvert('avatar', (v) => (v as num?)?.toInt()),
        xp: $checkedConvert('xp', (v) => (v as num?)?.toInt()),
        elo: $checkedConvert('elo', (v) => (v as num?)?.toInt()),
        streak: $checkedConvert('streak', (v) => (v as num?)?.toInt()),
        level: $checkedConvert('level', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$BoardRowToJson(BoardRow instance) => <String, dynamic>{
  'rank': ?instance.rank,
  'userId': ?instance.userId,
  'name': ?instance.name,
  'avatar': ?instance.avatar,
  'xp': ?instance.xp,
  'elo': ?instance.elo,
  'streak': ?instance.streak,
  'level': ?instance.level,
};
