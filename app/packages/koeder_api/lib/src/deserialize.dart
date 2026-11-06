import 'package:koeder_api/src/model/action_request.dart';
import 'package:koeder_api/src/model/action_result.dart';
import 'package:koeder_api/src/model/board_row.dart';
import 'package:koeder_api/src/model/check_request.dart';
import 'package:koeder_api/src/model/check_result.dart';
import 'package:koeder_api/src/model/code_response.dart';
import 'package:koeder_api/src/model/difficulty_setting.dart';
import 'package:koeder_api/src/model/duel_ref.dart';
import 'package:koeder_api/src/model/energy.dart';
import 'package:koeder_api/src/model/evaluation.dart';
import 'package:koeder_api/src/model/finding.dart';
import 'package:koeder_api/src/model/generate_request.dart';
import 'package:koeder_api/src/model/generated_response.dart';
import 'package:koeder_api/src/model/guest_request.dart';
import 'package:koeder_api/src/model/join_request.dart';
import 'package:koeder_api/src/model/login_request.dart';
import 'package:koeder_api/src/model/me_response.dart';
import 'package:koeder_api/src/model/practice_request.dart';
import 'package:koeder_api/src/model/public_info.dart';
import 'package:koeder_api/src/model/public_scenario.dart';
import 'package:koeder_api/src/model/red_flag.dart';
import 'package:koeder_api/src/model/register_request.dart';
import 'package:koeder_api/src/model/scenario.dart';
import 'package:koeder_api/src/model/settings_request.dart';
import 'package:koeder_api/src/model/today_shift.dart';
import 'package:koeder_api/src/model/token_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'ActionRequest':
          return ActionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActionResult':
          return ActionResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BoardRow':
          return BoardRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckRequest':
          return CheckRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckResult':
          return CheckResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeResponse':
          return CodeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DifficultySetting':
          return DifficultySetting.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DuelRef':
          return DuelRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Energy':
          return Energy.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Evaluation':
          return Evaluation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Finding':
          return Finding.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GenerateRequest':
          return GenerateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GeneratedResponse':
          return GeneratedResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GuestRequest':
          return GuestRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JoinRequest':
          return JoinRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginRequest':
          return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeResponse':
          return MeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PracticeRequest':
          return PracticeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicInfo':
          return PublicInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicScenario':
          return PublicScenario.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RedFlag':
          return RedFlag.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterRequest':
          return RegisterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Scenario':
          return Scenario.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SettingsRequest':
          return SettingsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TodayShift':
          return TodayShift.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenResponse':
          return TokenResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }