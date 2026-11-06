import 'duel_client.dart';
import 'models.dart';

/// Everything the game needs from "the backend". Two implementations:
/// the real server, and a fully local one so the game keeps working with no network at all.
abstract class GameRepo {
  bool get offline;

  /// Turns the current guest into an account. Returns the session token. Throws [AuthFailed].
  Future<String> register(String email, String password, String? displayName);

  /// Returns the session token. Throws [AuthFailed].
  Future<String> login(String email, String password);

  /// Stops whatever runs in the background for this identity.
  void close();

  Future<Me> me();
  Future<Me> updateSettings({String? displayName, int? avatar, String? locale, String? mode, bool? publicBoard});
  Future<Me> demoReset();
  Future<Map<String, dynamic>> exportData();
  Future<void> deleteAccount();

  Future<TodayShift> today();
  Future<ActionResult> act(String shiftId, String scenarioId, String action, int ms);
  Future<Evaluation> practice({required String scenarioId, required String context, String? action, List<String>? flags, required int ms});
  Future<List<Scenario>> reviewDue();

  /// The next shift of the day. There is no limit; an unfinished shift is returned as it is.
  Future<TodayShift> nextShift();

  /// The next questions of the endless mode. This never runs dry.
  Future<List<Scenario>> endless({String? difficulty});
  Future<List<Scenario>> swipeDeck();
  Future<List<Scenario>> flagsDeck();
  Future<List<Scenario>> moduleLesson(int module);

  Future<List<BoardRow>> leaderboard(String scope);
  Future<List<Map<String, dynamic>>> cases();
  Future<CheckResult> checkMessage({String? text, String? imageBase64, String? mediaType});

  DuelClient duelClient();
  Future<void> queueDuel();
  Future<void> leaveQueue();
  Future<String> createFriendly();

  /// [level] is rookie, analyst, veteran or ciso. Null lets the bot match the player.
  Future<String> friendlyAgainstBot({String? level});

  /// Returns the duel id. Throws [DuelJoinFailed] for an unknown or used code.
  Future<String> joinFriendly(String code);
}

enum AuthFailure { badLogin, emailTaken, needsServer, other }

class AuthFailed implements Exception {
  AuthFailed(this.reason);
  final AuthFailure reason;
}

class DuelJoinFailed implements Exception {}
