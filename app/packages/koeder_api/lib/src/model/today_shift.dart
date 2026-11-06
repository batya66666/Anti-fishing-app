//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/public_scenario.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_shift.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayShift {
  /// Returns a new [TodayShift] instance.
  TodayShift({

     this.id,

     this.date,

     this.completed,

     this.score,

     this.scenarios,

     this.answered,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'completed',
    required: false,
    includeIfNull: false,
  )


  final bool? completed;



  @JsonKey(
    
    name: r'score',
    required: false,
    includeIfNull: false,
  )


  final int? score;



  @JsonKey(
    
    name: r'scenarios',
    required: false,
    includeIfNull: false,
  )


  final List<PublicScenario>? scenarios;



  @JsonKey(
    
    name: r'answered',
    required: false,
    includeIfNull: false,
  )


  final List<String>? answered;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TodayShift &&
      other.id == id &&
      other.date == date &&
      other.completed == completed &&
      other.score == score &&
      other.scenarios == scenarios &&
      other.answered == answered;

    @override
    int get hashCode =>
        id.hashCode +
        date.hashCode +
        completed.hashCode +
        score.hashCode +
        scenarios.hashCode +
        answered.hashCode;

  factory TodayShift.fromJson(Map<String, dynamic> json) => _$TodayShiftFromJson(json);

  Map<String, dynamic> toJson() => _$TodayShiftToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

