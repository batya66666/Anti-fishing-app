//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/energy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeResponse {
  /// Returns a new [MeResponse] instance.
  MeResponse({

     this.id,

     this.displayName,

     this.avatar,

     this.locale,

     this.mode,

     this.role,

     this.orgId,

     this.publicBoard,

     this.email,

     this.xp,

     this.level,

     this.title,

     this.levelFloor,

     this.levelCeil,

     this.coins,

     this.streak,

     this.bestStreak,

     this.streakFreezes,

     this.shiftsDone,

     this.attacksReported,

     this.attacksSeen,

     this.timesHacked,

     this.falseAlarms,

     this.answers,

     this.answersCorrect,

     this.elo,

     this.wins,

     this.losses,

     this.leagueTier,

     this.weeklyXp,

     this.reviewsDue,

     this.energy,

     this.moduleProgress,

     this.badges,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'avatar',
    required: false,
    includeIfNull: false,
  )


  final int? avatar;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final String? mode;



  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final String? role;



  @JsonKey(
    
    name: r'orgId',
    required: false,
    includeIfNull: false,
  )


  final String? orgId;



  @JsonKey(
    
    name: r'publicBoard',
    required: false,
    includeIfNull: false,
  )


  final bool? publicBoard;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'xp',
    required: false,
    includeIfNull: false,
  )


  final int? xp;



  @JsonKey(
    
    name: r'level',
    required: false,
    includeIfNull: false,
  )


  final int? level;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'levelFloor',
    required: false,
    includeIfNull: false,
  )


  final int? levelFloor;



  @JsonKey(
    
    name: r'levelCeil',
    required: false,
    includeIfNull: false,
  )


  final int? levelCeil;



  @JsonKey(
    
    name: r'coins',
    required: false,
    includeIfNull: false,
  )


  final int? coins;



  @JsonKey(
    
    name: r'streak',
    required: false,
    includeIfNull: false,
  )


  final int? streak;



  @JsonKey(
    
    name: r'bestStreak',
    required: false,
    includeIfNull: false,
  )


  final int? bestStreak;



  @JsonKey(
    
    name: r'streakFreezes',
    required: false,
    includeIfNull: false,
  )


  final int? streakFreezes;



  @JsonKey(
    
    name: r'shiftsDone',
    required: false,
    includeIfNull: false,
  )


  final int? shiftsDone;



  @JsonKey(
    
    name: r'attacksReported',
    required: false,
    includeIfNull: false,
  )


  final int? attacksReported;



  @JsonKey(
    
    name: r'attacksSeen',
    required: false,
    includeIfNull: false,
  )


  final int? attacksSeen;



  @JsonKey(
    
    name: r'timesHacked',
    required: false,
    includeIfNull: false,
  )


  final int? timesHacked;



  @JsonKey(
    
    name: r'falseAlarms',
    required: false,
    includeIfNull: false,
  )


  final int? falseAlarms;



  @JsonKey(
    
    name: r'answers',
    required: false,
    includeIfNull: false,
  )


  final int? answers;



  @JsonKey(
    
    name: r'answersCorrect',
    required: false,
    includeIfNull: false,
  )


  final int? answersCorrect;



  @JsonKey(
    
    name: r'elo',
    required: false,
    includeIfNull: false,
  )


  final int? elo;



  @JsonKey(
    
    name: r'wins',
    required: false,
    includeIfNull: false,
  )


  final int? wins;



  @JsonKey(
    
    name: r'losses',
    required: false,
    includeIfNull: false,
  )


  final int? losses;



  @JsonKey(
    
    name: r'leagueTier',
    required: false,
    includeIfNull: false,
  )


  final String? leagueTier;



  @JsonKey(
    
    name: r'weeklyXp',
    required: false,
    includeIfNull: false,
  )


  final int? weeklyXp;



  @JsonKey(
    
    name: r'reviewsDue',
    required: false,
    includeIfNull: false,
  )


  final int? reviewsDue;



  @JsonKey(
    
    name: r'energy',
    required: false,
    includeIfNull: false,
  )


  final Energy? energy;



  @JsonKey(
    
    name: r'moduleProgress',
    required: false,
    includeIfNull: false,
  )


  final Map<String, int>? moduleProgress;



  @JsonKey(
    
    name: r'badges',
    required: false,
    includeIfNull: false,
  )


  final List<String>? badges;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeResponse &&
      other.id == id &&
      other.displayName == displayName &&
      other.avatar == avatar &&
      other.locale == locale &&
      other.mode == mode &&
      other.role == role &&
      other.orgId == orgId &&
      other.publicBoard == publicBoard &&
      other.email == email &&
      other.xp == xp &&
      other.level == level &&
      other.title == title &&
      other.levelFloor == levelFloor &&
      other.levelCeil == levelCeil &&
      other.coins == coins &&
      other.streak == streak &&
      other.bestStreak == bestStreak &&
      other.streakFreezes == streakFreezes &&
      other.shiftsDone == shiftsDone &&
      other.attacksReported == attacksReported &&
      other.attacksSeen == attacksSeen &&
      other.timesHacked == timesHacked &&
      other.falseAlarms == falseAlarms &&
      other.answers == answers &&
      other.answersCorrect == answersCorrect &&
      other.elo == elo &&
      other.wins == wins &&
      other.losses == losses &&
      other.leagueTier == leagueTier &&
      other.weeklyXp == weeklyXp &&
      other.reviewsDue == reviewsDue &&
      other.energy == energy &&
      other.moduleProgress == moduleProgress &&
      other.badges == badges;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode +
        avatar.hashCode +
        locale.hashCode +
        mode.hashCode +
        role.hashCode +
        orgId.hashCode +
        publicBoard.hashCode +
        email.hashCode +
        xp.hashCode +
        level.hashCode +
        title.hashCode +
        levelFloor.hashCode +
        levelCeil.hashCode +
        coins.hashCode +
        streak.hashCode +
        bestStreak.hashCode +
        streakFreezes.hashCode +
        shiftsDone.hashCode +
        attacksReported.hashCode +
        attacksSeen.hashCode +
        timesHacked.hashCode +
        falseAlarms.hashCode +
        answers.hashCode +
        answersCorrect.hashCode +
        elo.hashCode +
        wins.hashCode +
        losses.hashCode +
        leagueTier.hashCode +
        weeklyXp.hashCode +
        reviewsDue.hashCode +
        energy.hashCode +
        moduleProgress.hashCode +
        badges.hashCode;

  factory MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

