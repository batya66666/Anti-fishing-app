//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'join_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JoinRequest {
  /// Returns a new [JoinRequest] instance.
  JoinRequest({

    required  this.code,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is JoinRequest &&
      other.code == code;

    @override
    int get hashCode =>
        code.hashCode;

  factory JoinRequest.fromJson(Map<String, dynamic> json) => _$JoinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JoinRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

