import 'dart:async';

import 'package:dio/dio.dart';
import 'package:koeder_api/koeder_api.dart' as api;

import '../core/config.dart';
import 'duel_client.dart';
import 'models.dart';
import 'offline_repo.dart';
import 'repository.dart';

/// The real server, through the client generated from the backend's OpenAPI contract (see scripts/gen_api.sh).
/// An API change on the server becomes a compile error here instead of a surprise on stage.
class RemoteRepo implements GameRepo {
  RemoteRepo._(this._dio, this._deviceId, this._locale, this._fallback) : _api = api.KoederApi(dio: _dio, interceptors: const []);

  final Dio _dio;
  final api.KoederApi _api;
  final String _deviceId;
  String _locale;
  final OfflineRepo _fallback;
  String? _token;
  DuelClient? _duel;

  /// Signed in with a password rather than as this device's guest.
  bool _account = false;
  bool get hasAccount => _account;

  /// Signs in as a guest. Throws if the server cannot be reached, and the app then starts offline.
  static Future<RemoteRepo> connect({required String deviceId, required String locale, required OfflineRepo fallback, String? session, String? displayName}) async {
    final dio = Dio(BaseOptions(baseUrl: Config.apiBase, connectTimeout: const Duration(seconds: 4), receiveTimeout: const Duration(seconds: 45)));
    final repo = RemoteRepo._(dio, deviceId, locale, fallback);
    if (session == null || !await repo._resume(session)) await repo._signIn(displayName);
    unawaited(repo._loadPublicInfo());
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (repo._token != null) o.headers['Authorization'] = 'Bearer ${repo._token}';
      h.next(o);
    }, onError: (e, h) async {
      // Expired guest token: sign in once more with the device id and repeat the request.
      // An account's password is never silently replaced by a guest: that would look like lost progress.
      if (e.response?.statusCode == 401 && !repo._account && e.requestOptions.extra['retried'] != true) {
        try {
          await repo._signIn(null);
          final o = e.requestOptions
            ..extra['retried'] = true
            ..headers['Authorization'] = 'Bearer ${repo._token}';
          return h.resolve(await dio.fetch(o));
        } catch (_) {}
      }
      h.next(e);
    }));
    return repo;
  }

  /// Continues a saved session. False if the token is no longer accepted.
  Future<bool> _resume(String session) async {
    try {
      await _dio.get<void>('/api/me', options: Options(headers: {'Authorization': 'Bearer $session'}));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      rethrow; // no network: the app starts offline
    }
    _token = session;
    _account = true;
    return true;
  }

  Future<void> _loadPublicInfo() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/public/info');
      Config.serverPublicUrl = r.data?['publicUrl'] as String?;
    } catch (_) {
      // QR codes then simply use the address the page came from.
    }
  }

  @override
  Future<String> register(String email, String password, String? displayName) async {
    try {
      final r = await _api.getAuthApi().register(registerRequest: api.RegisterRequest(email: email, password: password, displayName: displayName));
      return _adopt(r.data!.token!);
    } on DioException catch (e) {
      throw AuthFailed(switch (e.response?.statusCode) {
        409 => AuthFailure.emailTaken,
        null => AuthFailure.needsServer,
        _ => AuthFailure.other,
      });
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final r = await _api.getAuthApi().login(loginRequest: api.LoginRequest(email: email, password: password));
      return _adopt(r.data!.token!);
    } on DioException catch (e) {
      throw AuthFailed(switch (e.response?.statusCode) {
        401 || 400 => AuthFailure.badLogin,
        null => AuthFailure.needsServer,
        _ => AuthFailure.other,
      });
    }
  }

  String _adopt(String token) {
    _token = token;
    _account = true;
    _duel?.dispose(); // its connection was opened with the old identity
    _duel = null;
    return token;
  }

  @override
  void close() {
    _duel?.dispose();
    _duel = null;
  }

  Future<void> _signIn(String? displayName) async {
    final r = await _api.getAuthApi().guest(guestRequest: api.GuestRequest(deviceId: _deviceId, displayName: displayName, locale: _locale));
    _token = r.data!.token;
  }

  // Generated transfer objects become the app's own models here: this file is the only place that knows both.
  Me _me(api.MeResponse dto) => Me.fromJson(dto.toJson());
  List<Scenario> _scenarios(List<api.PublicScenario>? list) => (list ?? const []).map((s) => Scenario.fromJson(s.toJson())).toList();

  static bool _isNetwork(DioException e) =>
      e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || (e.type == DioExceptionType.unknown && e.response == null);

  @override
  bool get offline => false;

  @override
  Future<Me> me() async => _me((await _api.getProfileApi().me()).data!);

  @override
  Future<Me> updateSettings({String? displayName, int? avatar, String? locale, String? mode, bool? publicBoard}) async {
    if (locale != null) _locale = locale;
    final r = await _api.getProfileApi().update(settingsRequest: api.SettingsRequest(displayName: displayName, avatar: avatar, locale: locale, mode: mode, publicBoard: publicBoard));
    return _me(r.data!);
  }

  @override
  Future<Me> demoReset() async => _me((await _api.getProfileApi().demoReset()).data!);

  @override
  Future<Map<String, dynamic>> exportData() async => Map<String, dynamic>.from((await _dio.get<Map<String, dynamic>>('/api/me/export')).data!);

  @override
  Future<void> deleteAccount() => _api.getProfileApi().delete();

  @override
  Future<TodayShift> today() async => TodayShift.fromJson((await _api.getPlayApi().today()).data!.toJson());

  /// If the network drops mid-shift the answer is judged locally, so the game never stops on stage.
  @override
  Future<ActionResult> act(String shiftId, String scenarioId, String action, int ms) async {
    try {
      final r = await _api.getPlayApi().act(id: shiftId, actionRequest: api.ActionRequest(scenarioId: scenarioId, action: action, ms: ms));
      return ActionResult.fromJson(r.data!.toJson());
    } on DioException catch (e) {
      if (!_isNetwork(e)) rethrow;
      final evaluation = await _fallback.judge(scenarioId, action, ms);
      return ActionResult(evaluation, 0, 0, false);
    }
  }

  @override
  Future<Evaluation> practice({required String scenarioId, required String context, String? action, List<String>? flags, required int ms}) async {
    try {
      final r = await _api.getPlayApi().practice(practiceRequest: api.PracticeRequest(scenarioId: scenarioId, context: context, action: action, flags: flags, ms: ms));
      return Evaluation.fromJson(r.data!.toJson());
    } on DioException catch (e) {
      if (!_isNetwork(e)) rethrow;
      return _fallback.practice(scenarioId: scenarioId, context: context, action: action, flags: flags, ms: ms);
    }
  }

  @override
  Future<List<Scenario>> reviewDue() async => _scenarios((await _api.getPlayApi().reviewDue()).data);

  @override
  Future<TodayShift> nextShift() async => TodayShift.fromJson((await _api.getPlayApi().nextShift()).data!.toJson());

  @override
  Future<List<Scenario>> endless({String? difficulty}) async => _scenarios((await _api.getPlayApi().endless(difficulty: difficulty)).data);

  @override
  Future<List<Scenario>> swipeDeck() async => _scenarios((await _api.getPlayApi().swipeDeck()).data);

  @override
  Future<List<Scenario>> flagsDeck() async => _scenarios((await _api.getPlayApi().flagsDeck()).data);

  @override
  Future<List<Scenario>> moduleLesson(int module) async => _scenarios((await _api.getPlayApi().module(module: module)).data);

  @override
  Future<List<BoardRow>> leaderboard(String scope) async {
    final r = await _api.getProfileApi().leaderboard(scope: scope);
    return (r.data ?? const <api.BoardRow>[]).map((e) => BoardRow.fromJson(e.toJson())).toList();
  }

  /// Case files are free-form story documents without a schema in the contract, so they bypass the typed client.
  @override
  Future<List<Map<String, dynamic>>> cases() async {
    final r = await _dio.get<List<dynamic>>('/api/cases', queryParameters: {'locale': _locale});
    return (r.data ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<CheckResult> checkMessage({String? text, String? imageBase64, String? mediaType}) async {
    try {
      final r = await _api.getAiApi().check(checkRequest: api.CheckRequest(text: text, imageBase64: imageBase64, mediaType: mediaType, locale: _locale));
      return CheckResult.fromJson(r.data!.toJson());
    } on DioException catch (e) {
      if (!_isNetwork(e)) rethrow;
      return _fallback.checkMessage(text: text, imageBase64: imageBase64, mediaType: mediaType);
    }
  }

  @override
  DuelClient duelClient() => _duel ??= StompDuelClient(_token!);

  @override
  Future<void> queueDuel() => _api.getDuelsApi().enqueue();

  @override
  Future<void> leaveQueue() => _api.getDuelsApi().leave();

  @override
  Future<String> createFriendly() async => (await _api.getDuelsApi().friendly()).data!.code!;

  @override
  Future<String> friendlyAgainstBot({String? level}) async => (await _api.getDuelsApi().friendlyBot(level: level)).data!.duelId!;

  @override
  Future<String> joinFriendly(String code) async {
    try {
      return (await _api.getDuelsApi().join1(code: code)).data!.duelId!;
    } on DioException catch (e) {
      if (e.response != null) throw DuelJoinFailed();
      rethrow;
    }
  }
}
