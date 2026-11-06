//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/red_flag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'evaluation.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Evaluation {
  /// Returns a new [Evaluation] instance.
  Evaluation({

     this.outcome,

     this.correct,

     this.attack,

     this.reported,

     this.points,

     this.xp,

     this.coins,

     this.flagsFound,

     this.flagsMissed,

     this.flagsWrong,

     this.redFlags,

     this.attackType,

     this.explanation,
  });

  @JsonKey(
    
    name: r'outcome',
    required: false,
    includeIfNull: false,
  )


  final EvaluationOutcomeEnum? outcome;



  @JsonKey(
    
    name: r'correct',
    required: false,
    includeIfNull: false,
  )


  final bool? correct;



  @JsonKey(
    
    name: r'attack',
    required: false,
    includeIfNull: false,
  )


  final bool? attack;



  @JsonKey(
    
    name: r'reported',
    required: false,
    includeIfNull: false,
  )


  final bool? reported;



  @JsonKey(
    
    name: r'points',
    required: false,
    includeIfNull: false,
  )


  final int? points;



  @JsonKey(
    
    name: r'xp',
    required: false,
    includeIfNull: false,
  )


  final int? xp;



  @JsonKey(
    
    name: r'coins',
    required: false,
    includeIfNull: false,
  )


  final int? coins;



  @JsonKey(
    
    name: r'flagsFound',
    required: false,
    includeIfNull: false,
  )


  final int? flagsFound;



  @JsonKey(
    
    name: r'flagsMissed',
    required: false,
    includeIfNull: false,
  )


  final int? flagsMissed;



  @JsonKey(
    
    name: r'flagsWrong',
    required: false,
    includeIfNull: false,
  )


  final int? flagsWrong;



  @JsonKey(
    
    name: r'redFlags',
    required: false,
    includeIfNull: false,
  )


  final List<RedFlag>? redFlags;



  @JsonKey(
    
    name: r'attackType',
    required: false,
    includeIfNull: false,
  )


  final String? attackType;



  @JsonKey(
    
    name: r'explanation',
    required: false,
    includeIfNull: false,
  )


  final String? explanation;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Evaluation &&
      other.outcome == outcome &&
      other.correct == correct &&
      other.attack == attack &&
      other.reported == reported &&
      other.points == points &&
      other.xp == xp &&
      other.coins == coins &&
      other.flagsFound == flagsFound &&
      other.flagsMissed == flagsMissed &&
      other.flagsWrong == flagsWrong &&
      other.redFlags == redFlags &&
      other.attackType == attackType &&
      other.explanation == explanation;

    @override
    int get hashCode =>
        outcome.hashCode +
        correct.hashCode +
        attack.hashCode +
        reported.hashCode +
        points.hashCode +
        xp.hashCode +
        coins.hashCode +
        flagsFound.hashCode +
        flagsMissed.hashCode +
        flagsWrong.hashCode +
        redFlags.hashCode +
        attackType.hashCode +
        explanation.hashCode;

  factory Evaluation.fromJson(Map<String, dynamic> json) => _$EvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum EvaluationOutcomeEnum {
@JsonValue(r'CORRECT')
CORRECT(r'CORRECT'),
@JsonValue(r'SAFE')
SAFE(r'SAFE'),
@JsonValue(r'HACKED')
HACKED(r'HACKED'),
@JsonValue(r'FALSE_ALARM')
FALSE_ALARM(r'FALSE_ALARM'),
@JsonValue(r'MISSED')
MISSED(r'MISSED');

const EvaluationOutcomeEnum(this.value);

final String value;

@override
String toString() => value;
}


