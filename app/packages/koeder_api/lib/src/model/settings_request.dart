//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'settings_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SettingsRequest {
  /// Returns a new [SettingsRequest] instance.
  SettingsRequest({

     this.displayName,

     this.avatar,

     this.locale,

     this.mode,

     this.publicBoard,
  });

  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'avatar',
    required: false,
    includeIfNull: false,
  )


  final int? avatar;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final String? mode;



  @JsonKey(
    
    name: r'publicBoard',
    required: false,
    includeIfNull: false,
  )


  final bool? publicBoard;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SettingsRequest &&
      other.displayName == displayName &&
      other.avatar == avatar &&
      other.locale == locale &&
      other.mode == mode &&
      other.publicBoard == publicBoard;

    @override
    int get hashCode =>
        displayName.hashCode +
        avatar.hashCode +
        locale.hashCode +
        mode.hashCode +
        publicBoard.hashCode;

  factory SettingsRequest.fromJson(Map<String, dynamic> json) => _$SettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

