//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'practice_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PracticeRequest {
  /// Returns a new [PracticeRequest] instance.
  PracticeRequest({

    required  this.scenarioId,

     this.context,

     this.action,

     this.flags,

     this.ms,
  });

  @JsonKey(
    
    name: r'scenarioId',
    required: true,
    includeIfNull: false,
  )


  final String scenarioId;



  @JsonKey(
    
    name: r'context',
    required: false,
    includeIfNull: false,
  )


  final String? context;



  @JsonKey(
    
    name: r'action',
    required: false,
    includeIfNull: false,
  )


  final String? action;



  @JsonKey(
    
    name: r'flags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? flags;



          // minimum: 0
  @JsonKey(
    
    name: r'ms',
    required: false,
    includeIfNull: false,
  )


  final int? ms;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PracticeRequest &&
      other.scenarioId == scenarioId &&
      other.context == context &&
      other.action == action &&
      other.flags == flags &&
      other.ms == ms;

    @override
    int get hashCode =>
        scenarioId.hashCode +
        context.hashCode +
        action.hashCode +
        flags.hashCode +
        ms.hashCode;

  factory PracticeRequest.fromJson(Map<String, dynamic> json) => _$PracticeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

