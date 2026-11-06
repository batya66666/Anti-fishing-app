//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'generate_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateRequest {
  /// Returns a new [GenerateRequest] instance.
  GenerateRequest({

    required  this.companyName,

     this.industry,

     this.tools,

     this.partners,

     this.employees,

     this.count,

     this.locale,
  });

  @JsonKey(
    
    name: r'companyName',
    required: true,
    includeIfNull: false,
  )


  final String companyName;



  @JsonKey(
    
    name: r'industry',
    required: false,
    includeIfNull: false,
  )


  final String? industry;



  @JsonKey(
    
    name: r'tools',
    required: false,
    includeIfNull: false,
  )


  final String? tools;



  @JsonKey(
    
    name: r'partners',
    required: false,
    includeIfNull: false,
  )


  final String? partners;



          // minimum: 1
          // maximum: 100000
  @JsonKey(
    
    name: r'employees',
    required: false,
    includeIfNull: false,
  )


  final int? employees;



          // minimum: 1
          // maximum: 12
  @JsonKey(
    
    name: r'count',
    required: false,
    includeIfNull: false,
  )


  final int? count;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GenerateRequest &&
      other.companyName == companyName &&
      other.industry == industry &&
      other.tools == tools &&
      other.partners == partners &&
      other.employees == employees &&
      other.count == count &&
      other.locale == locale;

    @override
    int get hashCode =>
        companyName.hashCode +
        industry.hashCode +
        tools.hashCode +
        partners.hashCode +
        employees.hashCode +
        count.hashCode +
        locale.hashCode;

  factory GenerateRequest.fromJson(Map<String, dynamic> json) => _$GenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

