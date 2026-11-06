import 'models.dart';

/// Offline copy of the server rules in ScenarioEvaluator.java. The server stays authoritative whenever it is reachable.
class Evaluator {
  static int _speed(int ms) => (30 * (1 - ms.clamp(0, 20000) / 20000)).round();

  static List<RedFlag> _flags(Map<String, dynamic> s) =>
      ((s['red_flags'] as List?) ?? const []).map((e) => RedFlag.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  static Evaluation _build(Map<String, dynamic> s, String outcome, bool ok, bool reported, int points, {int found = 0, int missed = 0, int wrong = 0}) {
    return Evaluation(
      outcome: outcome,
      correct: ok,
      attack: s['is_attack'] == true,
      reported: reported,
      points: points,
      xp: points ~/ 5 < 1 ? 1 : points ~/ 5,
      coins: outcome == 'CORRECT' ? 5 : (outcome == 'SAFE' ? 2 : 0),
      redFlags: _flags(s),
      explanation: (s['explanation'] as String?) ?? '',
      flagsFound: found,
      flagsMissed: missed,
      flagsWrong: wrong,
    );
  }

  static Evaluation action(Map<String, dynamic> s, String action, int ms) {
    final attack = s['is_attack'] == true;
    final correct = List<String>.from((s['correct_actions'] as List?) ?? const []);
    final dangerous = List<String>.from((s['dangerous_actions'] as List?) ?? const []);
    String outcome;
    int points;
    if (dangerous.contains(action)) {
      outcome = 'HACKED';
      points = 0;
    } else if (correct.isNotEmpty && correct.first == action) {
      outcome = 'CORRECT';
      points = (attack ? 100 : 80) + _speed(ms);
    } else if (correct.contains(action)) {
      outcome = 'SAFE';
      points = 60;
    } else if (!attack && (action == 'report' || action == 'delete')) {
      outcome = 'FALSE_ALARM';
      points = 10;
    } else {
      outcome = 'MISSED';
      points = 20;
    }
    return _build(s, outcome, outcome == 'CORRECT' || outcome == 'SAFE', attack && action == 'report', points);
  }

  static Evaluation verdict(Map<String, dynamic> s, String verdict, int ms) {
    final attack = s['is_attack'] == true;
    final said = verdict == 'attack';
    final ok = said == attack;
    final outcome = ok ? 'CORRECT' : (attack ? 'HACKED' : 'FALSE_ALARM');
    return _build(s, outcome, ok, attack && said, ok ? 50 + _speed(ms) : 0);
  }

  static bool matches(String target, String tapped) {
    if (target.startsWith('body:') && tapped.startsWith('body:')) {
      return tapped.toLowerCase().contains(target.substring(5).toLowerCase());
    }
    return target == tapped;
  }

  static Evaluation flags(Map<String, dynamic> s, List<String> tapped) {
    final flags = _flags(s);
    final found = flags.where((f) => tapped.any((t) => matches(f.target, t))).length;
    final wrong = tapped.where((t) => !flags.any((f) => matches(f.target, t))).length;
    final ok = flags.isEmpty ? wrong == 0 : found * 2 >= flags.length && wrong <= found;
    final points = (flags.isEmpty && wrong == 0) ? 80 : (found * 40 - wrong * 15).clamp(0, 1000);
    return _build(s, ok ? 'CORRECT' : 'MISSED', ok, false, points, found: found, missed: flags.length - found, wrong: wrong);
  }

  /// A small offline version of the server's rule engine for "check a message".
  static CheckResult checkLocally(String text, String locale) {
    final de = locale != 'en';
    final findings = <CheckFinding>[];
    var score = 0;
    void rule(RegExp r, int weight, String titleDe, String titleEn, String detailDe, String detailEn) {
      if (r.hasMatch(text)) {
        score += weight;
        findings.add(CheckFinding(de ? titleDe : titleEn, de ? detailDe : detailEn));
      }
    }

    rule(RegExp(r'\.(exe|scr|bat|cmd|ps1|vbs|js|hta|lnk|iso|img|docm|xlsm|apk)\b', caseSensitive: false), 45, 'Gefährlicher Dateityp', 'Dangerous file type',
        'Diese Datei kann Programmcode ausführen. Nicht öffnen.', 'This file can run code. Do not open it.');
    rule(RegExp(r'passwort|kennwort|\bpin\b|\btan\b|zugangsdaten|kartendaten|password|credentials|card details', caseSensitive: false), 30, 'Fragt nach Zugangsdaten', 'Asks for credentials',
        'Banken, IT und Behörden fragen nie per Nachricht danach.', 'Banks, IT and authorities never ask for this by message.');
    rule(RegExp(r'iban|bankverbindung|überweis|gutschein|bitcoin|krypto|bank details|wire transfer|gift card|crypto', caseSensitive: false), 25, 'Geld oder Bankdaten', 'Money or bank details',
        'Prüfe das über einen zweiten, bekannten Kanal.', 'Verify through a second, known channel.');
    rule(RegExp(r'dringend|sofort|umgehend|gesperrt|sperrung|läuft ab|urgent|immediately|suspended|expires?', caseSensitive: false), 20, 'Künstlicher Zeitdruck', 'Artificial urgency',
        'Zeitdruck soll dich vom Nachdenken abhalten.', 'Pressure is there to stop you from thinking.');
    rule(RegExp(r'vertraulich|niemandem|unter uns|confidential|tell anyone', caseSensitive: false), 20, 'Bitte um Geheimhaltung', 'Request for secrecy',
        'So bemerkt niemand den Betrug.', 'That way nobody notices the fraud.');
    rule(RegExp(r'neue nummer|hallo mama|hallo papa|new number|hi mum|hi mom|hi dad', caseSensitive: false), 35, 'Masche "neue Nummer"', '"New number" scam',
        'Ruf die alte, bekannte Nummer an.', 'Call the old, known number.');
    rule(RegExp(r'https?://|www\.|\.(xyz|top|click|shop|link|ru|cn)\b', caseSensitive: false), 15, 'Enthält einen Link', 'Contains a link',
        'Öffne die Seite lieber über dein Lesezeichen.', 'Rather open the site through your own bookmark.');

    score = score.clamp(0, 98);
    final verdict = score >= 50 ? 'dangerous' : (score >= 20 ? 'suspicious' : 'unclear');
    final recommendation = switch (verdict) {
      'dangerous' => de ? 'Nicht klicken, nicht antworten. Im Büro an die IT melden, privat löschen.' : 'Do not click or reply. At work report it to IT, at home delete it.',
      'suspicious' => de ? 'Prüfe die Nachricht über einen zweiten Kanal.' : 'Verify through a second channel.',
      _ => de ? 'Keine typischen Warnzeichen gefunden. Das ist keine Garantie.' : 'No typical warning signs found. That is no guarantee.',
    };
    return CheckResult(verdict: verdict, riskScore: score, findings: findings, recommendation: recommendation, source: 'rules');
  }
}
