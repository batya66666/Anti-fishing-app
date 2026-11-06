//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'check_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckRequest {
  /// Returns a new [CheckRequest] instance.
  CheckRequest({

     this.text,

     this.imageBase64,

     this.mediaType,

     this.locale,
  });

  @JsonKey(
    
    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;



  @JsonKey(
    
    name: r'imageBase64',
    required: false,
    includeIfNull: false,
  )


  final String? imageBase64;



  @JsonKey(
    
    name: r'mediaType',
    required: false,
    includeIfNull: false,
  )


  final String? mediaType;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckRequest &&
      other.text == text &&
      other.imageBase64 == imageBase64 &&
      other.mediaType == mediaType &&
      other.locale == locale;

    @override
    int get hashCode =>
        text.hashCode +
        imageBase64.hashCode +
        mediaType.hashCode +
        locale.hashCode;

  factory CheckRequest.fromJson(Map<String, dynamic> json) => _$CheckRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

