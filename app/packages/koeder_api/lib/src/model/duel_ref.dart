//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'duel_ref.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DuelRef {
  /// Returns a new [DuelRef] instance.
  DuelRef({

     this.duelId,
  });

  @JsonKey(
    
    name: r'duelId',
    required: false,
    includeIfNull: false,
  )


  final String? duelId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DuelRef &&
      other.duelId == duelId;

    @override
    int get hashCode =>
        duelId.hashCode;

  factory DuelRef.fromJson(Map<String, dynamic> json) => _$DuelRefFromJson(json);

  Map<String, dynamic> toJson() => _$DuelRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

