//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'guest_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GuestRequest {
  /// Returns a new [GuestRequest] instance.
  GuestRequest({

    required  this.deviceId,

     this.displayName,

     this.locale,
  });

  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GuestRequest &&
      other.deviceId == deviceId &&
      other.displayName == displayName &&
      other.locale == locale;

    @override
    int get hashCode =>
        deviceId.hashCode +
        displayName.hashCode +
        locale.hashCode;

  factory GuestRequest.fromJson(Map<String, dynamic> json) => _$GuestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GuestRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

