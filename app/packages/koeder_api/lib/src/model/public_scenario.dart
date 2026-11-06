//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'public_scenario.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicScenario {
  /// Returns a new [PublicScenario] instance.
  PublicScenario({

     this.id,

     this.type,

     this.locale,

     this.difficulty,

     this.module,

     this.content,
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
    
    name: r'module',
    required: false,
    includeIfNull: false,
  )


  final int? module;



  @JsonKey(
    
    name: r'content',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? content;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicScenario &&
      other.id == id &&
      other.type == type &&
      other.locale == locale &&
      other.difficulty == difficulty &&
      other.module == module &&
      other.content == content;

    @override
    int get hashCode =>
        id.hashCode +
        type.hashCode +
        locale.hashCode +
        difficulty.hashCode +
        module.hashCode +
        content.hashCode;

  factory PublicScenario.fromJson(Map<String, dynamic> json) => _$PublicScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$PublicScenarioToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

