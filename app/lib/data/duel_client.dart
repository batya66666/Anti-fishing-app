import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../core/config.dart';

/// The match as a stream of server events: state, countdown, round, progress, reaction, round_result, finished.
abstract class DuelClient {
  /// Fires with the duel id when matchmaking or a friend's join starts a match.
  Stream<String> get matchFound;

  /// Connection is ready. Safe to call more than once.
  Future<void> connect();

  Stream<Map<String, dynamic>> watch(String duelId);
  void ready(String duelId);
  void answer(String duelId, int round, {String? verdict, List<String>? flags});
  void react(String duelId, String emoji);
  void dispose();
}

/// Talks STOMP over WebSocket to Spring, with automatic reconnect for shaky venue Wi-Fi.
class StompDuelClient implements DuelClient {
  StompDuelClient(this._token);

  final String _token;
  StompClient? _client;
  Completer<void>? _connected;
  final _matchFound = StreamController<String>.broadcast();
  final Map<String, StreamController<Map<String, dynamic>>> _duels = {};
  final Map<String, void Function()> _unsubscribers = {};

  @override
  Stream<String> get matchFound => _matchFound.stream;

  @override
  Future<void> connect() {
    if (_connected != null) return _connected!.future;
    final done = Completer<void>();
    _connected = done;
    final client = StompClient(
      config: StompConfig(
        url: Config.wsUrl,
        reconnectDelay: const Duration(seconds: 2),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        stompConnectHeaders: {'Authorization': 'Bearer $_token'},
        onConnect: (_) {
          _client?.subscribe(
            destination: '/user/queue/match-found',
            callback: (frame) {
              final body = frame.body;
              if (body != null) _matchFound.add((jsonDecode(body) as Map)['duelId'] as String);
            },
          );
          // After a reconnect the old subscriptions are gone: restore them and ask for a fresh snapshot.
          for (final id in _duels.keys) {
            _subscribe(id);
            ready(id);
          }
          if (!done.isCompleted) done.complete();
        },
        onWebSocketError: (e) {
          if (!done.isCompleted) done.completeError(e as Object);
        },
        onStompError: (f) {
          if (!done.isCompleted) done.completeError(StateError(f.body ?? 'stomp error'));
        },
      ),
    );
    _client = client;
    client.activate();
    return done.future.timeout(const Duration(seconds: 8));
  }

  void _subscribe(String duelId) {
    _unsubscribers[duelId]?.call();
    _unsubscribers[duelId] = _client!.subscribe(
      destination: '/topic/duel/$duelId',
      callback: (frame) {
        final body = frame.body;
        if (body != null) _duels[duelId]?.add(Map<String, dynamic>.from(jsonDecode(body) as Map));
      },
    );
  }

  @override
  Stream<Map<String, dynamic>> watch(String duelId) {
    final controller = _duels.putIfAbsent(duelId, () => StreamController<Map<String, dynamic>>.broadcast());
    _subscribe(duelId);
    return controller.stream;
  }

  void _send(String destination, Map<String, dynamic> body) {
    _client?.send(destination: destination, body: jsonEncode(body), headers: {'content-type': 'application/json'});
  }

  @override
  void ready(String duelId) => _send('/app/duel/$duelId/ready', {});

  @override
  void answer(String duelId, int round, {String? verdict, List<String>? flags}) =>
      _send('/app/duel/$duelId/answer', {'round': round, 'verdict': ?verdict, 'flags': ?flags});

  @override
  void react(String duelId, String emoji) => _send('/app/duel/$duelId/react', {'emoji': emoji});

  @override
  void dispose() {
    for (final c in _duels.values) {
      c.close();
    }
    _duels.clear();
    _matchFound.close();
    _client?.deactivate();
  }
}
