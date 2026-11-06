//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'difficulty_setting.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DifficultySetting {
  /// Returns a new [DifficultySetting] instance.
  DifficultySetting({

     this.difficulty,
  });

  @JsonKey(
    
    name: r'difficulty',
    required: false,
    includeIfNull: false,
  )


  final String? difficulty;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DifficultySetting &&
      other.difficulty == difficulty;

    @override
    int get hashCode =>
        difficulty.hashCode;

  factory DifficultySetting.fromJson(Map<String, dynamic> json) => _$DifficultySettingFromJson(json);

  Map<String, dynamic> toJson() => _$DifficultySettingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

