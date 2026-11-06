//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/scenario.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneratedResponse {
  /// Returns a new [GeneratedResponse] instance.
  GeneratedResponse({

     this.scenarios,

     this.source_,
  });

  @JsonKey(
    
    name: r'scenarios',
    required: false,
    includeIfNull: false,
  )


  final List<Scenario>? scenarios;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneratedResponse &&
      other.scenarios == scenarios &&
      other.source_ == source_;

    @override
    int get hashCode =>
        scenarios.hashCode +
        source_.hashCode;

  factory GeneratedResponse.fromJson(Map<String, dynamic> json) => _$GeneratedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

