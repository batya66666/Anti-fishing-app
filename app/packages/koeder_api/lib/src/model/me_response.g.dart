// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponse _$MeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeResponse', json, ($checkedConvert) {
  final val = MeResponse(
    id: $checkedConvert('id', (v) => v as String?),
    displayName: $checkedConvert('displayName', (v) => v as String?),
    avatar: $checkedConvert('avatar', (v) => (v as num?)?.toInt()),
    locale: $checkedConvert('locale', (v) => v as String?),
    mode: $checkedConvert('mode', (v) => v as String?),
    role: $checkedConvert('role', (v) => v as String?),
    orgId: $checkedConvert('orgId', (v) => v as String?),
    publicBoard: $checkedConvert('publicBoard', (v) => v as bool?),
    email: $checkedConvert('email', (v) => v as String?),
    xp: $checkedConvert('xp', (v) => (v as num?)?.toInt()),
    level: $checkedConvert('level', (v) => (v as num?)?.toInt()),
    title: $checkedConvert('title', (v) => v as String?),
    levelFloor: $checkedConvert('levelFloor', (v) => (v as num?)?.toInt()),
    levelCeil: $checkedConvert('levelCeil', (v) => (v as num?)?.toInt()),
    coins: $checkedConvert('coins', (v) => (v as num?)?.toInt()),
    streak: $checkedConvert('streak', (v) => (v as num?)?.toInt()),
    bestStreak: $checkedConvert('bestStreak', (v) => (v as num?)?.toInt()),
    streakFreezes: $checkedConvert(
      'streakFreezes',
      (v) => (v as num?)?.toInt(),
    ),
    shiftsDone: $checkedConvert('shiftsDone', (v) => (v as num?)?.toInt()),
    attacksReported: $checkedConvert(
      'attacksReported',
      (v) => (v as num?)?.toInt(),
    ),
    attacksSeen: $checkedConvert('attacksSeen', (v) => (v as num?)?.toInt()),
    timesHacked: $checkedConvert('timesHacked', (v) => (v as num?)?.toInt()),
    falseAlarms: $checkedConvert('falseAlarms', (v) => (v as num?)?.toInt()),
    answers: $checkedConvert('answers', (v) => (v as num?)?.toInt()),
    answersCorrect: $checkedConvert(
      'answersCorrect',
      (v) => (v as num?)?.toInt(),
    ),
    elo: $checkedConvert('elo', (v) => (v as num?)?.toInt()),
    wins: $checkedConvert('wins', (v) => (v as num?)?.toInt()),
    losses: $checkedConvert('losses', (v) => (v as num?)?.toInt()),
    leagueTier: $checkedConvert('leagueTier', (v) => v as String?),
    weeklyXp: $checkedConvert('weeklyXp', (v) => (v as num?)?.toInt()),
    reviewsDue: $checkedConvert('reviewsDue', (v) => (v as num?)?.toInt()),
    energy: $checkedConvert(
      'energy',
      (v) => v == null ? null : Energy.fromJson(v as Map<String, dynamic>),
    ),
    moduleProgress: $checkedConvert(
      'moduleProgress',
      (v) => (v as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    ),
    moduleTotals: $checkedConvert(
      'moduleTotals',
      (v) => (v as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    ),
    forcedDifficulty: $checkedConvert('forcedDifficulty', (v) => v as String?),
    badges: $checkedConvert(
      'badges',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$MeResponseToJson(MeResponse instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'displayName': ?instance.displayName,
      'avatar': ?instance.avatar,
      'locale': ?instance.locale,
      'mode': ?instance.mode,
      'role': ?instance.role,
      'orgId': ?instance.orgId,
      'publicBoard': ?instance.publicBoard,
      'email': ?instance.email,
      'xp': ?instance.xp,
      'level': ?instance.level,
      'title': ?instance.title,
      'levelFloor': ?instance.levelFloor,
      'levelCeil': ?instance.levelCeil,
      'coins': ?instance.coins,
      'streak': ?instance.streak,
      'bestStreak': ?instance.bestStreak,
      'streakFreezes': ?instance.streakFreezes,
      'shiftsDone': ?instance.shiftsDone,
      'attacksReported': ?instance.attacksReported,
      'attacksSeen': ?instance.attacksSeen,
      'timesHacked': ?instance.timesHacked,
      'falseAlarms': ?instance.falseAlarms,
      'answers': ?instance.answers,
      'answersCorrect': ?instance.answersCorrect,
      'elo': ?instance.elo,
      'wins': ?instance.wins,
      'losses': ?instance.losses,
      'leagueTier': ?instance.leagueTier,
      'weeklyXp': ?instance.weeklyXp,
      'reviewsDue': ?instance.reviewsDue,
      'energy': ?instance.energy?.toJson(),
      'moduleProgress': ?instance.moduleProgress,
      'moduleTotals': ?instance.moduleTotals,
      'forcedDifficulty': ?instance.forcedDifficulty,
      'badges': ?instance.badges,
    };
