class Scenario {
  Scenario({required this.id, required this.type, required this.locale, required this.difficulty, required this.module, required this.content});

  factory Scenario.fromJson(Map<String, dynamic> j) => Scenario(
        id: j['id'] as String,
        type: j['type'] as String,
        locale: (j['locale'] as String?) ?? 'de',
        difficulty: (j['difficulty'] as String?) ?? 'silver',
        module: (j['module'] as num?)?.toInt() ?? 1,
        content: Map<String, dynamic>.from(j['content'] as Map),
      );

  final String id;
  final String type;
  final String locale;
  final String difficulty;
  final int module;
  final Map<String, dynamic> content;

  String str(String key) => (content[key] as String?) ?? '';
  List<Map<String, dynamic>> list(String key) => ((content[key] as List?) ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  /// Who the message claims to be from, for inbox rows.
  String get title => switch (type) {
        'email' => str('from_name'),
        'sms' || 'chat' => str('sender'),
        'call' => str('caller'),
        'url' => str('page_title'),
        'qr' => str('place'),
        'push' => str('app'),
        'file' => str('display_name').isNotEmpty ? str('display_name') : str('name'),
        _ => str('title'),
      };

  /// One line of preview text.
  String get snippet {
    final text = switch (type) {
      'email' => str('subject'),
      'sms' || 'chat' => list('messages').isEmpty ? '' : list('messages').last['text'] as String,
      'url' || 'qr' || 'file' => str('context'),
      'push' => str('title'),
      'scene' => str('text'),
      _ => '',
    };
    return text.replaceAll('\n', ' ');
  }
}

class RedFlag {
  RedFlag(this.target, this.hint);
  factory RedFlag.fromJson(Map<String, dynamic> j) => RedFlag(j['target'] as String, j['hint'] as String);
  final String target;
  final String hint;
}

class Evaluation {
  Evaluation({
    required this.outcome,
    required this.correct,
    required this.attack,
    required this.reported,
    required this.points,
    required this.xp,
    required this.coins,
    required this.redFlags,
    required this.explanation,
    this.flagsFound = 0,
    this.flagsMissed = 0,
    this.flagsWrong = 0,
  });

  factory Evaluation.fromJson(Map<String, dynamic> j) => Evaluation(
        outcome: j['outcome'] as String,
        correct: j['correct'] as bool,
        attack: j['attack'] as bool,
        reported: j['reported'] as bool,
        points: (j['points'] as num).toInt(),
        xp: (j['xp'] as num).toInt(),
        coins: (j['coins'] as num).toInt(),
        flagsFound: (j['flagsFound'] as num?)?.toInt() ?? 0,
        flagsMissed: (j['flagsMissed'] as num?)?.toInt() ?? 0,
        flagsWrong: (j['flagsWrong'] as num?)?.toInt() ?? 0,
        redFlags: ((j['redFlags'] as List?) ?? const []).map((e) => RedFlag.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        explanation: (j['explanation'] as String?) ?? '',
      );

  final String outcome; // CORRECT, SAFE, HACKED, FALSE_ALARM, MISSED
  final bool correct;
  final bool attack;
  final bool reported;
  final int points;
  final int xp;
  final int coins;
  final int flagsFound;
  final int flagsMissed;
  final int flagsWrong;
  final List<RedFlag> redFlags;
  final String explanation;

  bool get hacked => outcome == 'HACKED';
}

class ActionResult {
  ActionResult(this.evaluation, this.answered, this.total, this.shiftCompleted);
  factory ActionResult.fromJson(Map<String, dynamic> j) => ActionResult(
        Evaluation.fromJson(Map<String, dynamic>.from(j['evaluation'] as Map)),
        (j['answered'] as num).toInt(),
        (j['total'] as num).toInt(),
        j['shiftCompleted'] as bool,
      );
  final Evaluation evaluation;
  final int answered;
  final int total;
  final bool shiftCompleted;
}

class TodayShift {
  TodayShift({required this.id, required this.completed, required this.score, required this.scenarios, required this.answered});
  factory TodayShift.fromJson(Map<String, dynamic> j) => TodayShift(
        id: j['id'] as String,
        completed: j['completed'] as bool,
        score: (j['score'] as num).toInt(),
        scenarios: (j['scenarios'] as List).map((e) => Scenario.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        answered: List<String>.from(j['answered'] as List),
      );
  final String id;
  final bool completed;
  final int score;
  final List<Scenario> scenarios;
  final List<String> answered;
}

class Energy {
  Energy({required this.shiftCompleted, required this.shiftsToday});
  factory Energy.fromJson(Map<String, dynamic> j) => Energy(
        shiftCompleted: j['shiftCompleted'] as bool,
        shiftsToday: (j['shiftsToday'] as num).toInt(),
      );
  final bool shiftCompleted;
  final int shiftsToday;
}

class Me {
  Me.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        displayName = j['displayName'] as String,
        avatar = (j['avatar'] as num).toInt(),
        locale = j['locale'] as String,
        mode = j['mode'] as String,
        publicBoard = (j['publicBoard'] as bool?) ?? true,
        orgId = j['orgId'] as String?,
        email = j['email'] as String?,
        forcedDifficulty = j['forcedDifficulty'] as String?,
        xp = (j['xp'] as num).toInt(),
        level = (j['level'] as num).toInt(),
        title = j['title'] as String,
        levelFloor = (j['levelFloor'] as num).toInt(),
        levelCeil = (j['levelCeil'] as num).toInt(),
        coins = (j['coins'] as num).toInt(),
        streak = (j['streak'] as num).toInt(),
        bestStreak = (j['bestStreak'] as num).toInt(),
        streakFreezes = (j['streakFreezes'] as num).toInt(),
        shiftsDone = (j['shiftsDone'] as num).toInt(),
        attacksReported = (j['attacksReported'] as num).toInt(),
        attacksSeen = (j['attacksSeen'] as num).toInt(),
        timesHacked = (j['timesHacked'] as num).toInt(),
        falseAlarms = (j['falseAlarms'] as num).toInt(),
        answers = (j['answers'] as num).toInt(),
        answersCorrect = (j['answersCorrect'] as num).toInt(),
        elo = (j['elo'] as num).toInt(),
        wins = (j['wins'] as num).toInt(),
        losses = (j['losses'] as num).toInt(),
        leagueTier = j['leagueTier'] as String,
        weeklyXp = (j['weeklyXp'] as num).toInt(),
        reviewsDue = (j['reviewsDue'] as num).toInt(),
        energy = Energy.fromJson(Map<String, dynamic>.from(j['energy'] as Map)),
        moduleProgress = ((j['moduleProgress'] as Map?) ?? const {}).map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt())),
        moduleTotals = ((j['moduleTotals'] as Map?) ?? const {}).map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt())),
        badges = List<String>.from((j['badges'] as List?) ?? const []);

  final String id;
  final String displayName;
  final int avatar;
  final String locale;
  final String mode;
  final bool publicBoard;
  final String? orgId;

  /// Null for a guest.
  final String? email;

  /// A level the company's manager pinned for everyone, or null.
  final String? forcedDifficulty;
  final int xp;
  final int level;
  final String title;
  final int levelFloor;
  final int levelCeil;
  final int coins;
  final int streak;
  final int bestStreak;
  final int streakFreezes;
  final int shiftsDone;
  final int attacksReported;
  final int attacksSeen;
  final int timesHacked;
  final int falseAlarms;
  final int answers;
  final int answersCorrect;
  final int elo;
  final int wins;
  final int losses;
  final String leagueTier;
  final int weeklyXp;
  final int reviewsDue;
  final Energy energy;
  final Map<int, int> moduleProgress;
  final Map<int, int> moduleTotals;
  final List<String> badges;

  bool get simple => mode == 'simple';
  bool get registered => email != null;

  /// The first module of the learning path that is not finished yet, or null when all are.
  int? get nextModule {
    for (var n = 1; n <= 13; n++) {
      if ((moduleProgress[n] ?? 0) < (moduleTotals[n] ?? 0)) return n;
    }
    return null;
  }
  double get levelProgress => levelCeil <= levelFloor ? 1 : ((xp - levelFloor) / (levelCeil - levelFloor)).clamp(0, 1);
  int? get reportingRate => attacksSeen == 0 ? null : (100 * attacksReported / attacksSeen).round();
  int? get accuracy => answers == 0 ? null : (100 * answersCorrect / answers).round();
}

class BoardRow {
  BoardRow.fromJson(Map<String, dynamic> j)
      : rank = (j['rank'] as num).toInt(),
        userId = j['userId'] as String,
        name = j['name'] as String,
        avatar = (j['avatar'] as num).toInt(),
        xp = (j['xp'] as num).toInt(),
        elo = (j['elo'] as num).toInt(),
        streak = (j['streak'] as num).toInt(),
        level = (j['level'] as num).toInt();
  final int rank;
  final String userId;
  final String name;
  final int avatar;
  final int xp;
  final int elo;
  final int streak;
  final int level;
}

class CheckFinding {
  CheckFinding(this.title, this.detail);
  final String title;
  final String detail;
}

class CheckResult {
  CheckResult({required this.verdict, required this.riskScore, required this.findings, required this.recommendation, required this.source});
  factory CheckResult.fromJson(Map<String, dynamic> j) => CheckResult(
        verdict: j['verdict'] as String,
        riskScore: (j['riskScore'] as num).toInt(),
        findings: ((j['findings'] as List?) ?? const []).map((e) => CheckFinding((e as Map)['title'] as String, e['detail'] as String)).toList(),
        recommendation: j['recommendation'] as String,
        source: j['source'] as String,
      );
  final String verdict;
  final int riskScore;
  final List<CheckFinding> findings;
  final String recommendation;
  final String source;
}
