//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'board_row.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BoardRow {
  /// Returns a new [BoardRow] instance.
  BoardRow({

     this.rank,

     this.userId,

     this.name,

     this.avatar,

     this.xp,

     this.elo,

     this.streak,

     this.level,
  });

  @JsonKey(
    
    name: r'rank',
    required: false,
    includeIfNull: false,
  )


  final int? rank;



  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'avatar',
    required: false,
    includeIfNull: false,
  )


  final int? avatar;



  @JsonKey(
    
    name: r'xp',
    required: false,
    includeIfNull: false,
  )


  final int? xp;



  @JsonKey(
    
    name: r'elo',
    required: false,
    includeIfNull: false,
  )


  final int? elo;



  @JsonKey(
    
    name: r'streak',
    required: false,
    includeIfNull: false,
  )


  final int? streak;



  @JsonKey(
    
    name: r'level',
    required: false,
    includeIfNull: false,
  )


  final int? level;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BoardRow &&
      other.rank == rank &&
      other.userId == userId &&
      other.name == name &&
      other.avatar == avatar &&
      other.xp == xp &&
      other.elo == elo &&
      other.streak == streak &&
      other.level == level;

    @override
    int get hashCode =>
        rank.hashCode +
        userId.hashCode +
        name.hashCode +
        avatar.hashCode +
        xp.hashCode +
        elo.hashCode +
        streak.hashCode +
        level.hashCode;

  factory BoardRow.fromJson(Map<String, dynamic> json) => _$BoardRowFromJson(json);

  Map<String, dynamic> toJson() => _$BoardRowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

