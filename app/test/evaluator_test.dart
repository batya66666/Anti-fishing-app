import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:koeder/data/evaluator.dart';

/// The offline rules must match the server's (ScenarioEvaluator.java), so the game behaves the same with or without network.
void main() {
  final attack = {
    'is_attack': true,
    'correct_actions': ['report', 'delete'],
    'dangerous_actions': ['open_attachment'],
    'red_flags': [
      {'target': 'from_email', 'hint': 'x'},
      {'target': 'body:innerhalb von 24 Stunden', 'hint': 'y'},
      {'target': 'attachment:0', 'hint': 'z'},
    ],
    'explanation': 'e',
  };
  final legit = {
    'is_attack': false,
    'correct_actions': ['open', 'reply'],
    'dangerous_actions': <String>[],
    'red_flags': <Map<String, String>>[],
    'explanation': 'e',
  };

  test('reporting beats deleting', () {
    final report = Evaluator.action(attack, 'report', 20000);
    final delete = Evaluator.action(attack, 'delete', 20000);
    expect(report.outcome, 'CORRECT');
    expect(report.reported, isTrue);
    expect(delete.outcome, 'SAFE');
    expect(report.points, greaterThan(delete.points));
  });

  test('opening the attachment means hacked', () {
    final e = Evaluator.action(attack, 'open_attachment', 500);
    expect(e.hacked, isTrue);
    expect(e.points, 0);
  });

  test('a report on a genuine message is a false alarm', () {
    expect(Evaluator.action(legit, 'report', 500).outcome, 'FALSE_ALARM');
  });

  test('speed bonus is 30 at most', () {
    expect(Evaluator.action(legit, 'open', 0).points, 110);
    expect(Evaluator.action(legit, 'open', 60000).points, 80);
  });

  test('a tapped sentence counts if it contains the flagged phrase', () {
    final e = Evaluator.flags(attack, ['from_email', 'body:Bitte zahlen Sie innerhalb von 24 Stunden den Betrag.']);
    expect(e.flagsFound, 2);
    expect(e.flagsMissed, 1);
    expect(e.correct, isTrue);
  });

  test('wild tapping loses', () {
    final e = Evaluator.flags(attack, ['subject', 'body:Guten Tag', 'link:0']);
    expect(e.flagsWrong, 3);
    expect(e.correct, isFalse);
  });

  test('local message check flags a classic scam and never declares a message safe', () {
    final scam = Evaluator.checkLocally('Dringend! Passwort sofort bestätigen: login-check.xyz', 'de');
    expect(scam.verdict, 'dangerous');
    final calm = Evaluator.checkLocally('Treffen wir uns um 12?', 'de');
    expect(calm.verdict, 'unclear');
    expect(calm.recommendation, contains('keine Garantie'));
  });

  test('bundled offline content is in sync with the source of truth', () {
    for (final locale in ['de', 'en']) {
      final bundled = jsonDecode(File('assets/content/scenarios_$locale.json').readAsStringSync()) as List;
      final source = <dynamic>[];
      for (final f in Directory('../content/scenarios/$locale').listSync().whereType<File>()) {
        source.addAll(jsonDecode(f.readAsStringSync()) as List);
      }
      expect(bundled.length, source.length, reason: 'run: dart run tool/sync_content.dart');
    }
  });
}
