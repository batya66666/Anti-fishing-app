//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'public_info.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicInfo {
  /// Returns a new [PublicInfo] instance.
  PublicInfo({

     this.publicUrl,
  });

  @JsonKey(
    
    name: r'publicUrl',
    required: false,
    includeIfNull: false,
  )


  final String? publicUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicInfo &&
      other.publicUrl == publicUrl;

    @override
    int get hashCode =>
        publicUrl.hashCode;

  factory PublicInfo.fromJson(Map<String, dynamic> json) => _$PublicInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PublicInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

