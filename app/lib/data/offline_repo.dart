import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'duel_client.dart';
import 'evaluator.dart';
import 'models.dart';
import 'repository.dart';

/// The whole game without a server: scenarios from the bundled assets, progress in local storage.
/// The rules mirror the backend (see evaluator.dart); nothing here is authoritative for competition.
class OfflineRepo implements GameRepo {
  OfflineRepo(this._prefs, this._locale);

  final SharedPreferences _prefs;
  String _locale;
  final Map<String, List<Map<String, dynamic>>> _pool = {};
  final Map<String, List<Map<String, dynamic>>> _cases = {};
  LocalDuelClient? _duel;

  static const firstShift = ['mail-team-lunch', 'sms-parcel', 'mail-invoice-exe', 'call-ceo-fraud', 'mail-supplier-legit', 'url-subdomain', 'push-mfa-fatigue', 'mail-it-maintenance'];

  Future<List<Map<String, dynamic>>> _load() async {
    return _pool[_locale] ??= (jsonDecode(await rootBundle.loadString('assets/content/scenarios_$_locale.json')) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> _raw(String id) async => (await _load()).firstWhere((s) => s['id'] == id);

  String get _today {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Map<String, dynamic> get _state => jsonDecode(_prefs.getString('offline_state') ?? '{}') as Map<String, dynamic>;
  Future<void> _save(Map<String, dynamic> state) => _prefs.setString('offline_state', jsonEncode(state));

  int _level(int xp) {
    const t = [0, 150, 400, 800, 1400, 2200, 3200, 4500];
    var level = 1;
    for (var i = 0; i < t.length; i++) {
      if (xp >= t[i]) level = i + 1;
    }
    return level;
  }

  @override
  bool get offline => true;

  @override
  Future<Me> me() async {
    const titles = ['Praktikant', 'Junior', 'Sachbearbeiter', 'Senior', 'Teamleiter', 'Abteilungsleiter', 'Security Lead', 'CISO'];
    const thresholds = [0, 150, 400, 800, 1400, 2200, 3200, 4500];
    final s = _state;
    final xp = (s['xp'] as int?) ?? 0;
    final level = _level(xp);
    final shift = (s['shift'] as Map?) ?? const {};
    final isToday = shift['date'] == _today;
    final done = isToday && shift['completed'] == true;
    final swipes = s['swipeDate'] == _today ? (s['swipes'] as int? ?? 0) : 0;
    final due = _dueIds(s).length;
    return Me.fromJson({
      'id': 'local',
      'displayName': s['name'] ?? (_locale == 'en' ? 'Guest' : 'Gast'),
      'avatar': s['avatar'] ?? 0,
      'locale': _locale,
      'mode': s['mode'] ?? 'standard',
      'publicBoard': false,
      'xp': xp,
      'level': level,
      'title': titles[level - 1],
      'levelFloor': thresholds[level - 1],
      'levelCeil': level >= thresholds.length ? thresholds.last : thresholds[level],
      'coins': s['coins'] ?? 0,
      'streak': s['streak'] ?? 0,
      'bestStreak': s['bestStreak'] ?? 0,
      'streakFreezes': 1,
      'shiftsDone': s['shiftsDone'] ?? 0,
      'attacksReported': s['reported'] ?? 0,
      'attacksSeen': s['seen'] ?? 0,
      'timesHacked': s['hacked'] ?? 0,
      'falseAlarms': s['falseAlarms'] ?? 0,
      'answers': s['answers'] ?? 0,
      'answersCorrect': s['correct'] ?? 0,
      'elo': s['elo'] ?? 1000,
      'wins': s['wins'] ?? 0,
      'losses': s['losses'] ?? 0,
      'leagueTier': 'bronze',
      'weeklyXp': s['xp'] ?? 0,
      'reviewsDue': due,
      'energy': {'shiftAvailable': !done, 'shiftCompleted': done, 'swipeRoundsLeft': 3 - swipes, 'swipeRoundsPerDay': 3},
      'moduleProgress': <String, int>{},
      'badges': List<String>.from((s['badges'] as List?) ?? const []),
    });
  }

  @override
  Future<Me> updateSettings({String? displayName, int? avatar, String? locale, String? mode, bool? publicBoard}) async {
    final s = _state;
    if (displayName != null) s['name'] = displayName;
    if (avatar != null) s['avatar'] = avatar;
    if (mode != null) s['mode'] = mode;
    if (locale != null) _locale = locale;
    await _save(s);
    return me();
  }

  @override
  Future<Me> demoReset() async {
    final s = _state..remove('shift');
    s['swipes'] = 0;
    final review = Map<String, dynamic>.from((s['review'] as Map?) ?? const {});
    s['review'] = review.map((k, v) => MapEntry(k, 0));
    await _save(s);
    return me();
  }

  @override
  Future<Map<String, dynamic>> exportData() async => _state;

  @override
  Future<void> deleteAccount() => _prefs.remove('offline_state');

  @override
  Future<TodayShift> today() async {
    final s = _state;
    var shift = (s['shift'] as Map?)?.cast<String, dynamic>();
    final pool = await _load();
    if (shift == null || shift['date'] != _today) {
      final first = (s['shiftsDone'] as int? ?? 0) == 0 && s['mode'] != 'simple';
      List<String> ids;
      if (first) {
        ids = firstShift;
      } else {
        final simple = s['mode'] == 'simple';
        final rnd = Random(DateTime.now().day * 31 + DateTime.now().month);
        final eligible = pool.where((x) => !simple || x['consumer'] == true).toList()..shuffle(rnd);
        final attacks = eligible.where((x) => x['is_attack'] == true).take(4);
        final legit = eligible.where((x) => x['is_attack'] != true).take(4);
        ids = [...attacks, ...legit].map((x) => x['id'] as String).toList()..shuffle(rnd);
      }
      shift = {'id': 'local-$_today', 'date': _today, 'ids': ids, 'answered': <String>[], 'score': 0, 'completed': false, 'correct': 0};
      s['shift'] = shift;
      await _save(s);
    }
    final ids = List<String>.from(shift['ids'] as List);
    return TodayShift(
      id: shift['id'] as String,
      completed: shift['completed'] as bool,
      score: shift['score'] as int,
      scenarios: ids.map((id) => Scenario.fromJson(pool.firstWhere((x) => x['id'] == id))).toList(),
      answered: List<String>.from(shift['answered'] as List),
    );
  }

  Future<Evaluation> judge(String scenarioId, String action, int ms) async => Evaluator.action(await _raw(scenarioId), action, ms);

  @override
  Future<ActionResult> act(String shiftId, String scenarioId, String action, int ms) async {
    final e = await judge(scenarioId, action, ms);
    final s = _state;
    final shift = (s['shift'] as Map).cast<String, dynamic>();
    final answered = List<String>.from(shift['answered'] as List);
    if (!answered.contains(scenarioId)) answered.add(scenarioId);
    shift['answered'] = answered;
    shift['score'] = (shift['score'] as int) + e.points;
    shift['correct'] = (shift['correct'] as int) + (e.correct ? 1 : 0);
    final total = (shift['ids'] as List).length;
    final done = answered.length >= total;
    _record(s, scenarioId, e, false);
    if (done && shift['completed'] != true) {
      shift['completed'] = true;
      s['shiftsDone'] = (s['shiftsDone'] as int? ?? 0) + 1;
      s['xp'] = (s['xp'] as int? ?? 0) + 30 + (shift['correct'] == total ? 30 : 0);
      s['coins'] = (s['coins'] as int? ?? 0) + 10;
      _badge(s, 'first_shift');
      if (shift['correct'] == total) _badge(s, 'perfect_shift');
    }
    s['shift'] = shift;
    await _save(s);
    return ActionResult(e, answered.length, total, done);
  }

  void _badge(Map<String, dynamic> s, String badge) {
    final badges = List<String>.from((s['badges'] as List?) ?? const []);
    if (!badges.contains(badge)) badges.add(badge);
    s['badges'] = badges;
  }

  void _record(Map<String, dynamic> s, String id, Evaluation e, bool isReview) {
    s['xp'] = (s['xp'] as int? ?? 0) + e.xp;
    s['coins'] = (s['coins'] as int? ?? 0) + e.coins;
    s['answers'] = (s['answers'] as int? ?? 0) + 1;
    if (e.correct) s['correct'] = (s['correct'] as int? ?? 0) + 1;
    if (e.attack) s['seen'] = (s['seen'] as int? ?? 0) + 1;
    if (e.reported) {
      s['reported'] = (s['reported'] as int? ?? 0) + 1;
      _badge(s, 'first_report');
    }
    if (e.hacked) {
      s['hacked'] = (s['hacked'] as int? ?? 0) + 1;
      _badge(s, 'learned_the_hard_way');
    }
    if (e.outcome == 'FALSE_ALARM') s['falseAlarms'] = (s['falseAlarms'] as int? ?? 0) + 1;
    // Streak: touched today, compared to the last active day.
    final last = s['lastDay'] as String?;
    if (last != _today) {
      final y = DateTime.now().subtract(const Duration(days: 1));
      final wasYesterday = last == '${y.year}-${y.month}-${y.day}';
      s['streak'] = wasYesterday ? (s['streak'] as int? ?? 0) + 1 : 1;
      s['bestStreak'] = max(s['bestStreak'] as int? ?? 0, s['streak'] as int);
      s['lastDay'] = _today;
    }
    // Leitner, same schedule as the server: the value is the due time in ms.
    final review = Map<String, dynamic>.from((s['review'] as Map?) ?? const {});
    final boxes = Map<String, dynamic>.from((s['boxes'] as Map?) ?? const {});
    const days = [1, 3, 7, 14, 30];
    if (!e.correct) {
      boxes[id] = 1;
      review[id] = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
    } else if (isReview && boxes.containsKey(id)) {
      final box = (boxes[id] as int) + 1;
      if (box > days.length) {
        boxes.remove(id);
        review.remove(id);
      } else {
        boxes[id] = box;
        review[id] = DateTime.now().add(Duration(days: days[box - 1])).millisecondsSinceEpoch;
      }
    }
    s['review'] = review;
    s['boxes'] = boxes;
  }

  List<String> _dueIds(Map<String, dynamic> s) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final review = (s['review'] as Map?) ?? const {};
    return review.entries.where((e) => (e.value as int) <= now).map((e) => e.key as String).toList();
  }

  @override
  Future<Evaluation> practice({required String scenarioId, required String context, String? action, List<String>? flags, required int ms}) async {
    final raw = await _raw(scenarioId);
    final e = switch (context) {
      'swipe' => Evaluator.verdict(raw, action ?? '', ms),
      'flags' => Evaluator.flags(raw, flags ?? const []),
      _ => Evaluator.action(raw, action ?? '', ms),
    };
    final s = _state;
    _record(s, scenarioId, e, context == 'review');
    await _save(s);
    return e;
  }

  @override
  Future<List<Scenario>> reviewDue() async {
    final ids = _dueIds(_state);
    final pool = await _load();
    return pool.where((x) => ids.contains(x['id'])).map(Scenario.fromJson).toList();
  }

  @override
  Future<List<Scenario>> swipeDeck() async {
    final s = _state;
    final used = s['swipeDate'] == _today ? (s['swipes'] as int? ?? 0) : 0;
    if (used >= 3) throw LimitReached();
    s['swipeDate'] = _today;
    s['swipes'] = used + 1;
    await _save(s);
    final pool = (await _load()).where((x) => x['type'] != 'call' && x['type'] != 'scene').toList()..shuffle();
    return pool.take(20).map(Scenario.fromJson).toList();
  }

  @override
  Future<List<Scenario>> flagsDeck() async {
    final pool = (await _load()).where((x) => x['type'] == 'email' && x['is_attack'] == true && (x['red_flags'] as List).length >= 2).toList()..shuffle();
    return pool.take(5).map(Scenario.fromJson).toList();
  }

  @override
  Future<List<Scenario>> moduleLesson(int module) async => (await _load()).where((x) => x['module'] == module).map(Scenario.fromJson).toList();

  @override
  Future<List<BoardRow>> leaderboard(String scope) async {
    final me_ = await me();
    final rows = <Map<String, dynamic>>[
      {'userId': 'local', 'name': me_.displayName, 'avatar': me_.avatar, 'xp': me_.xp, 'elo': me_.elo, 'streak': me_.streak, 'level': me_.level},
    ];
    return rows.indexed.map((e) => BoardRow.fromJson({...e.$2, 'rank': e.$1 + 1})).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> cases() async {
    return _cases[_locale] ??= (jsonDecode(await rootBundle.loadString('assets/content/cases_$_locale.json')) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  @override
  Future<CheckResult> checkMessage({String? text, String? imageBase64, String? mediaType}) async => Evaluator.checkLocally(text ?? '', _locale);

  @override
  DuelClient duelClient() => _duel ??= LocalDuelClient(this);

  @override
  Future<void> queueDuel() async => (duelClient() as LocalDuelClient).startSoon();

  @override
  Future<void> leaveQueue() async => (duelClient() as LocalDuelClient).cancel();

  @override
  Future<String> createFriendly() async => throw DuelJoinFailed();

  @override
  Future<String> friendlyAgainstBot() async => (duelClient() as LocalDuelClient).newId();

  @override
  Future<String> joinFriendly(String code) async => throw DuelJoinFailed();

  Future<List<Map<String, dynamic>>> duelPool() => _load();

  Future<void> addDuelResult(int score, bool won) async {
    final s = _state;
    s['xp'] = (s['xp'] as int? ?? 0) + (won ? 40 : 15);
    s['wins'] = (s['wins'] as int? ?? 0) + (won ? 1 : 0);
    s['losses'] = (s['losses'] as int? ?? 0) + (won ? 0 : 1);
    _badge(s, 'first_duel');
    await _save(s);
  }

  String get locale => _locale;
}

/// Offline opponent: plays the server's event protocol against a local bot.
class LocalDuelClient implements DuelClient {
  LocalDuelClient(this._repo);

  final OfflineRepo _repo;
  final _found = StreamController<String>.broadcast();
  final _events = <String, StreamController<Map<String, dynamic>>>{};
  final _rnd = Random();
  final _timers = <Timer>[];
  Timer? _pending;
  List<Map<String, dynamic>> _rounds = [];
  int _current = -1;
  final _score = {'a': 0, 'b': 0};
  final _correct = {'a': 0, 'b': 0};
  final _per = {'a': <int>[], 'b': <int>[]};
  Map<String, int>? _roundPoints;
  Map<String, bool>? _roundCorrect;
  Map<String, int>? _roundMs;
  late DateTime _roundStart;
  String? _id;
  Timer? _roundTimer;

  String newId() => 'local-${DateTime.now().millisecondsSinceEpoch}';

  void startSoon() {
    _pending = Timer(const Duration(seconds: 2), () => _found.add(newId()));
  }

  void cancel() => _pending?.cancel();

  @override
  Stream<String> get matchFound => _found.stream;

  @override
  Future<void> connect() async {}

  @override
  Stream<Map<String, dynamic>> watch(String duelId) => _events.putIfAbsent(duelId, () => StreamController<Map<String, dynamic>>.broadcast()).stream;

  void _emit(Map<String, dynamic> m) => _events[_id]?.add(m);

  @override
  void ready(String duelId) {
    _id = duelId;
    _start();
  }

  Future<void> _start() async {
    final pool = (await _repo.duelPool()).where((s) => const ['email', 'sms', 'chat', 'qr', 'push', 'file', 'url'].contains(s['type'])).toList()..shuffle(_rnd);
    final flagRound = pool.firstWhere((s) => s['type'] == 'email' && s['is_attack'] == true && (s['red_flags'] as List).length >= 2);
    final urlRound = pool.firstWhere((s) => s['type'] == 'url');
    final others = pool.where((s) => s != flagRound && s != urlRound).take(3).toList();
    _rounds = [others[0], others[1], urlRound, flagRound, others[2]];
    _current = -1;
    _score['a'] = 0;
    _score['b'] = 0;
    _correct['a'] = 0;
    _correct['b'] = 0;
    _per['a'] = [];
    _per['b'] = [];
    _emit({
      'type': 'state',
      'phase': 'WAITING',
      'mode': 'friendly',
      'a': {'name': (await _repo.me()).displayName, 'avatar': (await _repo.me()).avatar, 'elo': (await _repo.me()).elo, 'bot': false, 'ready': true, 'score': 0, 'userId': 'local'},
      'b': {'name': 'Bot Otto', 'avatar': 3, 'elo': 1000, 'bot': true, 'ready': true, 'score': 0},
    });
    _emit({'type': 'countdown', 'ms': 3000});
    _timers.add(Timer(const Duration(seconds: 3), _next));
  }

  void _next() {
    _current++;
    if (_current >= _rounds.length) {
      _finish();
      return;
    }
    final raw = _rounds[_current];
    final kind = _current == 3 ? 'flags' : (_current == 2 ? 'url' : 'swipe');
    _roundPoints = {};
    _roundCorrect = {};
    _roundMs = {};
    _roundStart = DateTime.now();
    _emit({
      'type': 'round',
      'no': _current + 1,
      'total': _rounds.length,
      'kind': kind,
      'seconds': 15,
      'scenarios': {_repo.locale: raw},
    });
    final botDelay = 2000 + _rnd.nextInt(8000);
    final round = _current;
    _timers.add(Timer(Duration(milliseconds: botDelay), () {
      if (_current != round) return;
      final right = _rnd.nextDouble() < 0.68;
      final pts = right ? 100 + (50 * (1 - botDelay / 10000)).round().clamp(0, 50) : 0;
      _apply('b', pts, right, botDelay);
    }));
    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(seconds: 15), () {
      if (_current == round) _closeRound();
    });
  }

  void _apply(String who, int points, bool correct, int ms) {
    if (_roundPoints == null || _roundPoints!.containsKey(who)) return;
    _roundPoints![who] = points;
    _roundCorrect![who] = correct;
    _roundMs![who] = ms;
    _emit({'type': 'progress', 'player': who, 'round': _current + 1, 'ms': ms});
    if (_roundPoints!.length == 2) _closeRound();
  }

  @override
  void answer(String duelId, int round, {String? verdict, List<String>? flags}) {
    if (round != _current + 1) return;
    final raw = _rounds[_current];
    final ms = DateTime.now().difference(_roundStart).inMilliseconds;
    if (flags != null) {
      final e = Evaluator.flags(raw, flags);
      _apply('a', (e.flagsFound * 50 - e.flagsWrong * 25).clamp(0, 150), e.correct, ms);
    } else {
      final ok = (verdict == 'attack') == (raw['is_attack'] == true);
      _apply('a', ok ? 100 + (50 * (1 - ms / 10000)).round().clamp(0, 50) : 0, ok, ms);
    }
  }

  void _closeRound() {
    _roundTimer?.cancel();
    final raw = _rounds[_current];
    final pa = _roundPoints!['a'] ?? 0;
    final pb = _roundPoints!['b'] ?? 0;
    _score['a'] = _score['a']! + pa;
    _score['b'] = _score['b']! + pb;
    _per['a']!.add(pa);
    _per['b']!.add(pb);
    if (_roundCorrect!['a'] == true) _correct['a'] = _correct['a']! + 1;
    if (_roundCorrect!['b'] == true) _correct['b'] = _correct['b']! + 1;
    _roundPoints = null;
    _emit({
      'type': 'round_result',
      'no': _current + 1,
      'solutions': {
        _repo.locale: {'isAttack': raw['is_attack'], 'explanation': raw['explanation'], 'redFlags': raw['red_flags']}
      },
      'a': {'points': pa, 'correct': _roundCorrect!['a'] ?? false, 'ms': _roundMs!['a'] ?? 15000, 'total': _score['a']},
      'b': {'points': pb, 'correct': _roundCorrect!['b'] ?? false, 'ms': _roundMs!['b'] ?? 15000, 'total': _score['b']},
    });
    _timers.add(Timer(const Duration(milliseconds: 3500), _next));
  }

  void _finish() {
    final a = _score['a']!;
    final b = _score['b']!;
    _repo.addDuelResult(a, a > b);
    _emit({
      'type': 'finished',
      if (a != b) 'winner': a > b ? 'a' : 'b',
      'a': {'score': a, 'correct': _correct['a'], 'eloDelta': 0, 'elo': 1000, 'perRound': _per['a']},
      'b': {'score': b, 'correct': _correct['b'], 'eloDelta': 0, 'elo': 1000, 'perRound': _per['b']},
    });
  }

  @override
  void react(String duelId, String emoji) => _emit({'type': 'reaction', 'player': 'a', 'emoji': emoji});

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _roundTimer?.cancel();
    _pending?.cancel();
    _found.close();
  }
}
