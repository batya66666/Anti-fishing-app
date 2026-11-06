//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/red_flag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scenario.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Scenario {
  /// Returns a new [Scenario] instance.
  Scenario({

     this.id,

     this.type,

     this.locale,

     this.difficulty,

     this.isAttack,

     this.attackType,

     this.module,

     this.consumer,

     this.content,

     this.redFlags,

     this.correctActions,

     this.dangerousActions,

     this.explanation,

     this.tags,

     this.orgId,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final String? type;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'difficulty',
    required: false,
    includeIfNull: false,
  )


  final String? difficulty;



  @JsonKey(
    
    name: r'is_attack',
    required: false,
    includeIfNull: false,
  )


  final bool? isAttack;



  @JsonKey(
    
    name: r'attack_type',
    required: false,
    includeIfNull: false,
  )


  final String? attackType;



  @JsonKey(
    
    name: r'module',
    required: false,
    includeIfNull: false,
  )


  final int? module;



  @JsonKey(
    
    name: r'consumer',
    required: false,
    includeIfNull: false,
  )


  final bool? consumer;



  @JsonKey(
    
    name: r'content',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? content;



  @JsonKey(
    
    name: r'red_flags',
    required: false,
    includeIfNull: false,
  )


  final List<RedFlag>? redFlags;



  @JsonKey(
    
    name: r'correct_actions',
    required: false,
    includeIfNull: false,
  )


  final List<String>? correctActions;



  @JsonKey(
    
    name: r'dangerous_actions',
    required: false,
    includeIfNull: false,
  )


  final List<String>? dangerousActions;



  @JsonKey(
    
    name: r'explanation',
    required: false,
    includeIfNull: false,
  )


  final String? explanation;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(
    
    name: r'orgId',
    required: false,
    includeIfNull: false,
  )


  final String? orgId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Scenario &&
      other.id == id &&
      other.type == type &&
      other.locale == locale &&
      other.difficulty == difficulty &&
      other.isAttack == isAttack &&
      other.attackType == attackType &&
      other.module == module &&
      other.consumer == consumer &&
      other.content == content &&
      other.redFlags == redFlags &&
      other.correctActions == correctActions &&
      other.dangerousActions == dangerousActions &&
      other.explanation == explanation &&
      other.tags == tags &&
      other.orgId == orgId;

    @override
    int get hashCode =>
        id.hashCode +
        type.hashCode +
        locale.hashCode +
        difficulty.hashCode +
        isAttack.hashCode +
        attackType.hashCode +
        module.hashCode +
        consumer.hashCode +
        content.hashCode +
        redFlags.hashCode +
        correctActions.hashCode +
        dangerousActions.hashCode +
        explanation.hashCode +
        tags.hashCode +
        orgId.hashCode;

  factory Scenario.fromJson(Map<String, dynamic> json) => _$ScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$ScenarioToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

