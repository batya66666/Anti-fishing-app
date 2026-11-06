import 'package:flutter/foundation.dart';

/// Where the backend lives. On the web the default is the origin the page came from (Caddy serves both).
/// For local development or an APK: --dart-define=API_BASE=http://192.168.0.10:8080
class Config {
  static const String _define = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_define.isNotEmpty) return _define;
    return kIsWeb ? Uri.base.origin : 'http://10.0.2.2:8080';
  }

  static String get wsUrl {
    final uri = Uri.parse(apiBase);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}/ws';
  }

  /// What the server says phones should use. Needed when this laptop itself opens the game through localhost.
  static String? serverPublicUrl;

  /// The address a phone opens to play. Used in the QR codes.
  static String get publicBase {
    const define = String.fromEnvironment('PUBLIC_BASE');
    if (define.isNotEmpty) return define;
    if (kIsWeb) {
      final path = Uri.base.path.replaceFirst(RegExp(r'admin/?.*$'), '');
      final announced = serverPublicUrl;
      if (announced != null && _isLoopback(Uri.base.host)) return announced.endsWith('/') ? announced : '$announced/';
      return '${Uri.base.origin}$path';
    }
    return apiBase;
  }

  static bool _isLoopback(String host) => host == 'localhost' || host.startsWith('127.') || host == '::1';

  /// Plain http to another machine: whoever shares the network could read along.
  static bool get insecureConnection {
    final uri = Uri.parse(apiBase);
    return uri.scheme == 'http' && !_isLoopback(uri.host);
  }

  /// The game's address for people to type, without the duel part.
  static String get playAddress => publicBase;

  static String duelLink(String code) => '$publicBase#/duel/join/$code';
  static String get arenaLink => '$publicBase#/duel/arena';
}
