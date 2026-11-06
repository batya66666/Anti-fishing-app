// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TokenResponse', json, ($checkedConvert) {
      final val = TokenResponse(
        token: $checkedConvert('token', (v) => v as String?),
        userId: $checkedConvert('userId', (v) => v as String?),
        role: $checkedConvert('role', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TokenResponseToJson(TokenResponse instance) =>
    <String, dynamic>{
      'token': ?instance.token,
      'userId': ?instance.userId,
      'role': ?instance.role,
    };
