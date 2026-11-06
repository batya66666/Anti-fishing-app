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

     this.shiftCompleted,

     this.shiftsToday,
  });

  @JsonKey(
    
    name: r'shiftCompleted',
    required: false,
    includeIfNull: false,
  )


  final bool? shiftCompleted;



  @JsonKey(
    
    name: r'shiftsToday',
    required: false,
    includeIfNull: false,
  )


  final int? shiftsToday;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Energy &&
      other.shiftCompleted == shiftCompleted &&
      other.shiftsToday == shiftsToday;

    @override
    int get hashCode =>
        shiftCompleted.hashCode +
        shiftsToday.hashCode;

  factory Energy.fromJson(Map<String, dynamic> json) => _$EnergyFromJson(json);

  Map<String, dynamic> toJson() => _$EnergyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

