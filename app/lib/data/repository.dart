import 'duel_client.dart';
import 'models.dart';

/// Everything the game needs from "the backend". Two implementations:
/// the real server, and a fully local one so the game keeps working with no network at all.
abstract class GameRepo {
  bool get offline;

  Future<Me> me();
  Future<Me> updateSettings({String? displayName, int? avatar, String? locale, String? mode, bool? publicBoard});
  Future<Me> demoReset();
  Future<Map<String, dynamic>> exportData();
  Future<void> deleteAccount();

  Future<TodayShift> today();
  Future<ActionResult> act(String shiftId, String scenarioId, String action, int ms);
  Future<Evaluation> practice({required String scenarioId, required String context, String? action, List<String>? flags, required int ms});
  Future<List<Scenario>> reviewDue();

  /// Throws [LimitReached] when today's free rounds are used up.
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
  Future<String> friendlyAgainstBot();

  /// Returns the duel id. Throws [DuelJoinFailed] for an unknown or used code.
  Future<String> joinFriendly(String code);
}

class LimitReached implements Exception {}

class DuelJoinFailed implements Exception {}
