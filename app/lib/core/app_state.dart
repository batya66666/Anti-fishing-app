import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/models.dart';
import '../data/offline_repo.dart';
import '../data/remote_repo.dart';
import '../data/repository.dart';
import 'sfx.dart';

class AppState {
  const AppState({this.ready = false, this.onboarded = false, this.offline = false, this.locale = 'de', this.me, this.session = 0});
  final bool ready;
  final bool onboarded;
  final bool offline;
  final String locale;
  final Me? me;

  /// Counts up whenever the signed-in identity changes, so everything tied to the old one is rebuilt.
  final int session;

  bool get simple => me?.simple ?? false;

  AppState copyWith({bool? ready, bool? onboarded, bool? offline, String? locale, Me? me, int? session}) => AppState(
        ready: ready ?? this.ready,
        onboarded: onboarded ?? this.onboarded,
        offline: offline ?? this.offline,
        locale: locale ?? this.locale,
        me: me ?? this.me,
        session: session ?? this.session,
      );
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);

/// The repository in use. Set during bootstrap, before any screen needs it.
final repoProvider = Provider<GameRepo>((ref) {
  ref.watch(appProvider.select((s) => s.session));
  return ref.read(appProvider.notifier).repo;
});

class AppNotifier extends Notifier<AppState> {
  late GameRepo repo;
  late SharedPreferences _prefs;
  bool _started = false;
  int _session = 0;

  static const _deviceKey = 'device_id';
  static const _sessionKey = 'session_token';

  @override
  AppState build() => const AppState();

  Future<void> bootstrap() async {
    if (_started) return;
    _started = true;
    _prefs = await SharedPreferences.getInstance();
    final platform = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final locale = _prefs.getString('locale') ?? (platform == 'de' ? 'de' : 'en');
    Sfx.enabled = _prefs.getBool('sound') ?? true;
    final offlineRepo = OfflineRepo(_prefs, locale);
    final deviceId = await _deviceId();
    final session = await _readSecret(_sessionKey);
    var offline = false;
    try {
      final remote = await RemoteRepo.connect(deviceId: deviceId, locale: locale, fallback: offlineRepo, session: session);
      repo = remote;
      // The saved session has run out: back to a guest, and the player signs in again from the profile.
      if (session != null && !remote.hasAccount) await _writeSecret(_sessionKey, null);
    } catch (_) {
      repo = offlineRepo;
      offline = true;
    }
    final me = await repo.me();
    // The language chosen on this device wins, also over what a returning account last used.
    final Me shown = !offline && me.locale != locale ? await repo.updateSettings(locale: locale) : me;
    state = AppState(ready: true, onboarded: _prefs.getBool('onboarded') ?? false, offline: offline, locale: locale, me: shown, session: ++_session);
  }

  /// The id that identifies this device's guest account: a credential, so it goes into secure storage on phones.
  Future<String> _deviceId() async {
    final existing = await _readSecret(_deviceKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _writeSecret(_deviceKey, id);
    return id;
  }

  /// Secure storage on the web needs a secure context, which a laptop on the venue Wi-Fi over plain http does not have.
  Future<String?> _readSecret(String key) async => kIsWeb ? _prefs.getString(key) : await const FlutterSecureStorage().read(key: key);

  Future<void> _writeSecret(String key, String? value) async {
    if (kIsWeb) {
      value == null ? await _prefs.remove(key) : await _prefs.setString(key, value);
    } else {
      const storage = FlutterSecureStorage();
      value == null ? await storage.delete(key: key) : await storage.write(key: key, value: value);
    }
  }

  Future<void> refresh() async {
    final me = await repo.me();
    state = state.copyWith(me: me);
  }

  /// Registering turns the current guest into an account: everything played so far stays.
  Future<void> register(String email, String password, String name) async {
    final token = await repo.register(email, password, name.isEmpty ? null : name);
    await _writeSecret(_sessionKey, token);
    await _afterSignIn();
  }

  /// Signing in replaces the guest with the account's own progress.
  Future<void> login(String email, String password) async {
    final token = await repo.login(email, password);
    await _writeSecret(_sessionKey, token);
    await _afterSignIn();
  }

  Future<void> _afterSignIn() async {
    final me = await repo.updateSettings(locale: state.locale);
    state = state.copyWith(me: me, session: ++_session);
  }

  /// Back to the very start, as a new guest. The old device id must not lead back to anything.
  Future<void> logout() async {
    repo.close();
    await _writeSecret(_sessionKey, null);
    await _writeSecret(_deviceKey, null);
    await _prefs.setBool('onboarded', false);
    _started = false;
    state = const AppState();
    await bootstrap();
  }

  Future<void> finishOnboarding({required String locale, String? mode, String? name}) async {
    await _prefs.setBool('onboarded', true);
    await _prefs.setString('locale', locale);
    final me = await repo.updateSettings(locale: locale, mode: mode, displayName: name);
    state = state.copyWith(onboarded: true, locale: locale, me: me);
  }

  /// A jury member arriving through a QR code goes straight to the match, with sensible defaults.
  Future<void> skipOnboarding() async {
    if (state.onboarded) return;
    await _prefs.setBool('onboarded', true);
    state = state.copyWith(onboarded: true);
  }

  Future<void> setLocale(String locale) => updateSettings(locale: locale);

  Future<void> updateSettings({String? name, int? avatar, String? locale, String? mode, bool? publicBoard}) async {
    final me = await repo.updateSettings(displayName: name, avatar: avatar, locale: locale, mode: mode, publicBoard: publicBoard);
    if (locale != null) await _prefs.setString('locale', locale);
    state = state.copyWith(me: me, locale: locale);
  }

  Future<void> setSound(bool on) async {
    Sfx.enabled = on;
    await _prefs.setBool('sound', on);
    state = state.copyWith();
  }

  bool tourSeen(String tour) => _prefs.getBool('tour_$tour') ?? false;

  Future<void> markTour(String tour) => _prefs.setBool('tour_$tour', true);

  /// So that "repeat the tour" also shows the inbox and the mail again.
  Future<void> resetTours() async {
    for (final tour in const ['home', 'shift', 'mail']) {
      await _prefs.remove('tour_$tour');
    }
  }

  Future<void> demoReset() async {
    final me = await repo.demoReset();
    state = state.copyWith(me: me);
  }

  Future<void> deleteAccount() async {
    await repo.deleteAccount();
    repo.close();
    await _writeSecret(_sessionKey, null);
    await _writeSecret(_deviceKey, null);
    await _prefs.clear();
    _started = false;
    state = const AppState();
    await bootstrap();
  }
}
