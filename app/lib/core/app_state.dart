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
  const AppState({this.ready = false, this.onboarded = false, this.offline = false, this.locale = 'de', this.me});
  final bool ready;
  final bool onboarded;
  final bool offline;
  final String locale;
  final Me? me;

  bool get simple => me?.simple ?? false;

  AppState copyWith({bool? ready, bool? onboarded, bool? offline, String? locale, Me? me}) => AppState(
        ready: ready ?? this.ready,
        onboarded: onboarded ?? this.onboarded,
        offline: offline ?? this.offline,
        locale: locale ?? this.locale,
        me: me ?? this.me,
      );
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);

/// The repository in use. Set during bootstrap, before any screen needs it.
final repoProvider = Provider<GameRepo>((ref) => ref.watch(appProvider.notifier).repo);

class AppNotifier extends Notifier<AppState> {
  late GameRepo repo;
  late SharedPreferences _prefs;
  bool _started = false;

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
    var offline = false;
    try {
      repo = await RemoteRepo.connect(deviceId: deviceId, locale: locale, fallback: offlineRepo);
    } catch (_) {
      repo = offlineRepo;
      offline = true;
    }
    final me = await repo.me();
    state = AppState(ready: true, onboarded: _prefs.getBool('onboarded') ?? false, offline: offline, locale: offline ? locale : me.locale, me: me);
    if (!offline && me.locale != locale) {
      await _prefs.setString('locale', me.locale);
    }
  }

  /// The id that identifies this device's guest account: a credential, so it goes into secure storage on phones.
  Future<String> _deviceId() async {
    const key = 'device_id';
    if (kIsWeb) {
      // Secure storage on the web needs a secure context, which the hotspot fallback over plain http does not have.
      final existing = _prefs.getString(key);
      if (existing != null) return existing;
      final id = const Uuid().v4();
      await _prefs.setString(key, id);
      return id;
    }
    const storage = FlutterSecureStorage();
    final existing = await storage.read(key: key);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await storage.write(key: key, value: id);
    return id;
  }

  Future<void> refresh() async {
    final me = await repo.me();
    state = state.copyWith(me: me);
  }

  Future<void> finishOnboarding({required String locale, required String mode, String? name}) async {
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

  Future<void> demoReset() async {
    final me = await repo.demoReset();
    state = state.copyWith(me: me);
  }

  Future<void> deleteAccount() async {
    await repo.deleteAccount();
    await _prefs.clear();
    _started = false;
    state = const AppState();
    await bootstrap();
  }
}
