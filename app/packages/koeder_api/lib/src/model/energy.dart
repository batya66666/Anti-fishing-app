//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'energy.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Energy {
  /// Returns a new [Energy] instance.
  Energy({

     this.shiftAvailable,

     this.shiftCompleted,

     this.swipeRoundsLeft,

     this.swipeRoundsPerDay,
  });

  @JsonKey(
    
    name: r'shiftAvailable',
    required: false,
    includeIfNull: false,
  )


  final bool? shiftAvailable;



  @JsonKey(
    
    name: r'shiftCompleted',
    required: false,
    includeIfNull: false,
  )


  final bool? shiftCompleted;



  @JsonKey(
    
    name: r'swipeRoundsLeft',
    required: false,
    includeIfNull: false,
  )


  final int? swipeRoundsLeft;



  @JsonKey(
    
    name: r'swipeRoundsPerDay',
    required: false,
    includeIfNull: false,
  )


  final int? swipeRoundsPerDay;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Energy &&
      other.shiftAvailable == shiftAvailable &&
      other.shiftCompleted == shiftCompleted &&
      other.swipeRoundsLeft == swipeRoundsLeft &&
      other.swipeRoundsPerDay == swipeRoundsPerDay;

    @override
    int get hashCode =>
        shiftAvailable.hashCode +
        shiftCompleted.hashCode +
        swipeRoundsLeft.hashCode +
        swipeRoundsPerDay.hashCode;

  factory Energy.fromJson(Map<String, dynamic> json) => _$EnergyFromJson(json);

  Map<String, dynamic> toJson() => _$EnergyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

