//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:koeder_api/src/model/finding.dart';
import 'package:json_annotation/json_annotation.dart';

part 'check_result.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckResult {
  /// Returns a new [CheckResult] instance.
  CheckResult({

     this.verdict,

     this.riskScore,

     this.findings,

     this.recommendation,

     this.source_,
  });

  @JsonKey(
    
    name: r'verdict',
    required: false,
    includeIfNull: false,
  )


  final String? verdict;



  @JsonKey(
    
    name: r'riskScore',
    required: false,
    includeIfNull: false,
  )


  final int? riskScore;



  @JsonKey(
    
    name: r'findings',
    required: false,
    includeIfNull: false,
  )


  final List<Finding>? findings;



  @JsonKey(
    
    name: r'recommendation',
    required: false,
    includeIfNull: false,
  )


  final String? recommendation;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckResult &&
      other.verdict == verdict &&
      other.riskScore == riskScore &&
      other.findings == findings &&
      other.recommendation == recommendation &&
      other.source_ == source_;

    @override
    int get hashCode =>
        verdict.hashCode +
        riskScore.hashCode +
        findings.hashCode +
        recommendation.hashCode +
        source_.hashCode;

  factory CheckResult.fromJson(Map<String, dynamic> json) => _$CheckResultFromJson(json);

  Map<String, dynamic> toJson() => _$CheckResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

