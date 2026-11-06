import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/config.dart';

/// Talks to the organisation endpoints. Everything it can fetch is aggregate data.
class AdminApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: Config.apiBase, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 90)));
  String? _token;
  String? orgId;
  StompClient? _stomp;

  Options get _auth => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> login(String email, String password) async {
    final r = await _dio.post('/api/auth/login', data: {'email': email, 'password': password});
    _token = r.data['token'] as String;
    final me = await _dio.get('/api/me', options: _auth);
    orgId = me.data['orgId'] as String?;
  }

  Future<Map<String, dynamic>> dashboard() async {
    final r = await _dio.get('/api/orgs/$orgId/dashboard', options: _auth);
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<List<Map<String, dynamic>>> scenarios() async {
    final r = await _dio.get('/api/orgs/$orgId/scenarios', options: _auth);
    return (r.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> generate({required String company, required String industry, required String tools, required String partners, required int employees, required int count, required String locale}) async {
    final r = await _dio.post('/api/orgs/$orgId/scenarios/generate',
        data: {'companyName': company, 'industry': industry, 'tools': tools, 'partners': partners, 'employees': employees, 'count': count, 'locale': locale}, options: _auth);
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> publish(String id) => _dio.post('/api/orgs/$orgId/scenarios/$id/publish', options: _auth);

  Future<Uint8List> report(String locale) async {
    final r = await _dio.get<List<int>>('/api/orgs/$orgId/reports/compliance.pdf',
        queryParameters: {'locale': locale}, options: _auth.copyWith(responseType: ResponseType.bytes));
    return Uint8List.fromList(r.data!);
  }

  /// Live updates: the server pushes a fresh aggregate whenever someone in the company answers.
  void listen(void Function(Map<String, dynamic>) onData, void Function(bool connected) onStatus) {
    _stomp?.deactivate();
    final client = StompClient(
      config: StompConfig(
        url: Config.wsUrl,
        reconnectDelay: const Duration(seconds: 3),
        stompConnectHeaders: {'Authorization': 'Bearer $_token'},
        onConnect: (_) {
          onStatus(true);
          _stomp?.subscribe(
            destination: '/topic/org/$orgId/live',
            callback: (f) {
              if (f.body != null) onData(Map<String, dynamic>.from(jsonDecode(f.body!) as Map));
            },
          );
        },
        onWebSocketDone: () => onStatus(false),
        onWebSocketError: (_) => onStatus(false),
      ),
    );
    _stomp = client;
    client.activate();
  }

  void dispose() => _stomp?.deactivate();
}
