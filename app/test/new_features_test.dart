import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:koeder/core/l10n.dart';
import 'package:koeder/core/theme.dart';
import 'package:koeder/data/models.dart';
import 'package:koeder/effects/hacked_overlay.dart';
import 'package:koeder/effects/mascot.dart';
import 'package:koeder/features/play/scenario_player.dart';
import 'package:koeder/effects/tour.dart';
import 'package:koeder/simulators/common.dart';
import 'package:koeder/simulators/mail_sim.dart';
import 'package:koeder/simulators/scenario_view.dart';

Widget _host(Widget child) => MaterialApp(
      theme: K.theme(),
      locale: const Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: Scaffold(body: child),
    );

Scenario _pdfMail({Map<String, dynamic>? cta, String? qr, String? replyTo}) => Scenario(id: 'x', type: 'email', locale: 'de', difficulty: 'gold', module: 4, content: {
      'from_name': 'Personalabteilung',
      'from_email': 'personal@muster-automotive-hr.test',
      'reply_to': ?replyTo,
      'subject': 'Neue Abrechnung',
      'time': '09:14',
      'body_md': 'Die Anleitung finden Sie im Anhang.',
      'links': <Map<String, String>>[],
      'attachments': [
        {
          'name': 'Anleitung.pdf',
          'size_kb': 214,
          'pdf': {
            'issuer': 'Muster Automotive',
            'title': 'Umstellung Entgeltportal',
            'lines': ['Bitte melden Sie sich an.'],
            'cta': ?cta,
            'qr': ?qr,
          },
        }
      ],
    });

void main() {
  testWidgets('a PDF opens in the viewer without counting as an answer', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _pdfMail(cta: {'text': 'In OfficeCloud öffnen', 'href': 'https://officecloud-viewer.test/d'}), props: SimProps(onAction: actions.add))));
    await tester.tap(find.text('Anleitung.pdf'));
    await tester.pumpAndSettle();
    expect(find.text('Umstellung Entgeltportal'), findsOneWidget);
    expect(actions, isEmpty);
  });

  testWidgets('leaving the PDF lets the player still decide on the message', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _pdfMail(), props: SimProps(onAction: actions.add))));
    await tester.tap(find.text('Anleitung.pdf'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Melden'));
    expect(actions, ['report']);
  });

  testWidgets('the button in a PDF is the dangerous click', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _pdfMail(cta: {'text': 'In OfficeCloud öffnen', 'href': 'https://officecloud-viewer.test/d'}), props: SimProps(onAction: actions.add))));
    await tester.tap(find.text('Anleitung.pdf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In OfficeCloud öffnen'));
    await tester.pumpAndSettle();
    expect(actions, ['click_link']);
    expect(find.text('Umstellung Entgeltportal'), findsNothing);
  });

  testWidgets('scanning the QR code in a PDF is an action too', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _pdfMail(qr: 'https://muster-automotive-hr.test/sso'), props: SimProps(onAction: actions.add))));
    await tester.tap(find.text('Anleitung.pdf'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.qr_code_scanner));
    await tester.pumpAndSettle();
    expect(actions, ['scan_open']);
  });

  testWidgets('a different reply address only shows after tapping the sender', (tester) async {
    await tester.pumpWidget(_host(MailSim(s: _pdfMail(replyTo: 'chef@mailbox.test'), props: SimProps(onAction: (_) {}))));
    expect(find.textContaining('chef@mailbox.test'), findsNothing);
    await tester.tap(find.text('Personalabteilung'));
    await tester.pumpAndSettle();
    expect(find.textContaining('chef@mailbox.test'), findsOneWidget);
  });

  testWidgets('the verdict card shows what is inside a PDF', (tester) async {
    await tester.pumpWidget(_host(SizedBox(width: 400, height: 700, child: ScenarioCard(s: _pdfMail(cta: {'text': 'Öffnen', 'href': 'https://officecloud-viewer.test/d'})))));
    expect(find.text('Umstellung Entgeltportal'), findsOneWidget);
    expect(find.textContaining('officecloud-viewer.test'), findsOneWidget);
  });

  group('guided tour', () {
    // The fish keeps swimming, so the screen never settles by itself.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> start(WidgetTester tester, List<TourStep> Function(GlobalKey) steps, void Function() onDone) async {
      final key = GlobalKey();
      await tester.pumpWidget(_host(Builder(
        builder: (context) => Column(children: [
          TextButton(key: key, onPressed: () {}, child: const Text('Ziel')),
          TextButton(onPressed: () => runTour(context, steps(key)).then((_) => onDone()), child: const Text('Start')),
        ]),
      )));
      await tester.tap(find.text('Start'));
      await settle(tester);
    }

    testWidgets('walks through its steps with the fish and then gets out of the way', (tester) async {
      var done = false;
      await start(tester, (k) => [const TourStep(title: 'Hallo', body: 'Eins'), TourStep(target: k, title: 'Hier', body: 'Zwei')], () => done = true);
      expect(find.text('Hallo'), findsOneWidget);
      expect(find.byType(Mascot), findsOneWidget);
      await tester.tap(find.text('Weiter'));
      await settle(tester);
      expect(find.text('Hallo'), findsNothing);
      expect(find.text('Hier'), findsOneWidget);
      // The last step has nothing left to skip.
      expect(find.text('Überspringen'), findsNothing);
      await tester.tap(find.text('Los geht’s!'));
      await settle(tester);
      expect(find.text('Hier'), findsNothing);
      expect(done, isTrue);
    });

    testWidgets('can be skipped at once', (tester) async {
      var done = false;
      await start(tester, (k) => [const TourStep(title: 'Hallo', body: 'Eins'), TourStep(target: k, title: 'Hier', body: 'Zwei')], () => done = true);
      await tester.tap(find.text('Überspringen'));
      await settle(tester);
      expect(find.text('Hallo'), findsNothing);
      expect(done, isTrue);
    });

    testWidgets('blocks the app behind it while it runs', (tester) async {
      await start(tester, (k) => [const TourStep(title: 'Hallo', body: 'Eins')], () {});
      // The start button is still in the tree, but the scrim takes the tap.
      await tester.tap(find.text('Start'), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Hallo'), findsOneWidget);
    });
  });

  test('the next module is the first one not finished', () {
    Me me(Map<String, int> progress) => Me.fromJson({
          'id': 'x', 'displayName': 'x', 'avatar': 0, 'locale': 'de', 'mode': 'standard', 'xp': 0, 'level': 1, 'title': 't', 'levelFloor': 0, 'levelCeil': 1,
          'coins': 0, 'streak': 0, 'bestStreak': 0, 'streakFreezes': 0, 'shiftsDone': 0, 'attacksReported': 0, 'attacksSeen': 0, 'timesHacked': 0, 'falseAlarms': 0,
          'answers': 0, 'answersCorrect': 0, 'elo': 1000, 'wins': 0, 'losses': 0, 'leagueTier': 'bronze', 'weeklyXp': 0, 'reviewsDue': 0,
          'energy': {'shiftCompleted': false, 'shiftsToday': 0},
          'moduleProgress': progress,
          'moduleTotals': {'1': 2, '2': 2, '3': 1},
        });
    expect(me({}).nextModule, 1);
    expect(me({'1': 1}).nextModule, 1);
    expect(me({'1': 2}).nextModule, 2);
    expect(me({'1': 2, '2': 2, '3': 1}).nextModule, isNull);
  });

  group('what a mistake triggers', () {
    Evaluation wrong({required bool attack, required String outcome}) => Evaluation(outcome: outcome, correct: false, attack: attack, reported: false, points: 0, xp: 0, coins: 0, redFlags: const [], explanation: '');

    test('falling for an attack gets you hacked', () {
      expect(hackKindOf(wrong(attack: true, outcome: 'HACKED')), HackKind.attack);
      expect(hackKindOf(wrong(attack: true, outcome: 'MISSED')), HackKind.missed);
    });

    test('being wrong about a genuine message makes you paranoid, never hacked', () {
      expect(hackKindOf(wrong(attack: false, outcome: 'FALSE_ALARM')), HackKind.paranoid);
      expect(hackKindOf(wrong(attack: false, outcome: 'MISSED')), HackKind.paranoid);
    });
  });

  test('every case file names its sources, says what is reconstructed, and exists in both languages', () {
    final ids = <String, Set<String>>{};
    for (final locale in ['de', 'en']) {
      ids[locale] = {};
      for (final f in Directory('../content/cases/$locale').listSync().whereType<File>()) {
        final c = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        ids[locale]!.add(c['id'] as String);
        expect((c['sources'] as List), isNotEmpty, reason: f.path);
        expect(c['disclaimer'] as String, isNotEmpty, reason: f.path);
        final steps = c['steps'] as List;
        expect(steps, isNotEmpty, reason: f.path);
        for (final s in steps) {
          final options = s['options'] as List;
          // Each step can be survived and can be failed.
          expect(options.any((o) => o['stops'] == true), isTrue, reason: f.path);
          expect(options.any((o) => o['stops'] != true), isTrue, reason: f.path);
        }
      }
    }
    expect(ids['de'], ids['en']);
    expect(ids['de'], containsAll(['binance-2026', 'arup-2024', 'marks-spencer-2025', 'retool-2023', 'mgm-2023']));
  });
}
