//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'code_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeResponse {
  /// Returns a new [CodeResponse] instance.
  CodeResponse({

     this.code,
  });

  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeResponse &&
      other.code == code;

    @override
    int get hashCode =>
        code.hashCode;

  factory CodeResponse.fromJson(Map<String, dynamic> json) => _$CodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CodeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

