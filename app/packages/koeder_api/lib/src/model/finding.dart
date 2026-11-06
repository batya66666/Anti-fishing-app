//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'finding.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Finding {
  /// Returns a new [Finding] instance.
  Finding({

     this.title,

     this.detail,
  });

  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Finding &&
      other.title == title &&
      other.detail == detail;

    @override
    int get hashCode =>
        title.hashCode +
        detail.hashCode;

  factory Finding.fromJson(Map<String, dynamic> json) => _$FindingFromJson(json);

  Map<String, dynamic> toJson() => _$FindingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

