import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Sound and haptics in one place. All effects are optional: failure to play is never an error for the player.
class Sfx {
  Sfx._();

  static bool enabled = true;
  static final Map<String, AudioPlayer> _players = {};
  static AudioPlayer? _loop;

  static Future<void> play(String name, {double volume = 0.8}) async {
    if (!enabled) return;
    try {
      final player = _players.putIfAbsent(name, () => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      await player.stop();
      await player.play(AssetSource('audio/$name.wav'), volume: volume);
    } catch (_) {}
  }

  static Future<void> loop(String name, {double volume = 0.7}) async {
    if (!enabled) return;
    try {
      await stopLoop();
      final player = AudioPlayer();
      _loop = player;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('audio/$name.wav'), volume: volume);
    } catch (_) {}
  }

  static Future<void> stopLoop() async {
    final player = _loop;
    _loop = null;
    try {
      await player?.stop();
      await player?.dispose();
    } catch (_) {}
  }

  static void click() {
    HapticFeedback.selectionClick();
    play('click', volume: 0.5);
  }

  static void success() {
    HapticFeedback.mediumImpact();
    play('success');
  }

  static void error() {
    HapticFeedback.heavyImpact();
    play('error');
  }
}
