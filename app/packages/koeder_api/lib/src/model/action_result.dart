//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/evaluation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action_result.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActionResult {
  /// Returns a new [ActionResult] instance.
  ActionResult({

     this.evaluation,

     this.answered,

     this.total,

     this.shiftCompleted,
  });

  @JsonKey(
    
    name: r'evaluation',
    required: false,
    includeIfNull: false,
  )


  final Evaluation? evaluation;



  @JsonKey(
    
    name: r'answered',
    required: false,
    includeIfNull: false,
  )


  final int? answered;



  @JsonKey(
    
    name: r'total',
    required: false,
    includeIfNull: false,
  )


  final int? total;



  @JsonKey(
    
    name: r'shiftCompleted',
    required: false,
    includeIfNull: false,
  )


  final bool? shiftCompleted;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActionResult &&
      other.evaluation == evaluation &&
      other.answered == answered &&
      other.total == total &&
      other.shiftCompleted == shiftCompleted;

    @override
    int get hashCode =>
        evaluation.hashCode +
        answered.hashCode +
        total.hashCode +
        shiftCompleted.hashCode;

  factory ActionResult.fromJson(Map<String, dynamic> json) => _$ActionResultFromJson(json);

  Map<String, dynamic> toJson() => _$ActionResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

