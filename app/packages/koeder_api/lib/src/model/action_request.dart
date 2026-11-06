//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'action_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionRequest {
  /// Returns a new [ActionRequest] instance.
  ActionRequest({

    required  this.scenarioId,

    required  this.action,

     this.ms,
  });

  @JsonKey(
    
    name: r'scenarioId',
    required: true,
    includeIfNull: false,
  )


  final String scenarioId;



  @JsonKey(
    
    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final String action;



          // minimum: 0
  @JsonKey(
    
    name: r'ms',
    required: false,
    includeIfNull: false,
  )


  final int? ms;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActionRequest &&
      other.scenarioId == scenarioId &&
      other.action == action &&
      other.ms == ms;

    @override
    int get hashCode =>
        scenarioId.hashCode +
        action.hashCode +
        ms.hashCode;

  factory ActionRequest.fromJson(Map<String, dynamic> json) => _$ActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ActionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

