//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'red_flag.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RedFlag {
  /// Returns a new [RedFlag] instance.
  RedFlag({

     this.target,

     this.hint,
  });

  @JsonKey(
    
    name: r'target',
    required: false,
    includeIfNull: false,
  )


  final String? target;



  @JsonKey(
    
    name: r'hint',
    required: false,
    includeIfNull: false,
  )


  final String? hint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RedFlag &&
      other.target == target &&
      other.hint == hint;

    @override
    int get hashCode =>
        target.hashCode +
        hint.hashCode;

  factory RedFlag.fromJson(Map<String, dynamic> json) => _$RedFlagFromJson(json);

  Map<String, dynamic> toJson() => _$RedFlagToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

