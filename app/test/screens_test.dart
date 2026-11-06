import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koeder/core/l10n.dart';
import 'package:koeder/core/theme.dart';
import 'package:koeder/data/models.dart';
import 'package:koeder/simulators/common.dart';
import 'package:koeder/simulators/mail_sim.dart';

Widget _host(Widget child) => MaterialApp(
      theme: K.theme(),
      locale: const Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: Scaffold(body: child),
    );

Scenario _mail() => Scenario(id: 'x', type: 'email', locale: 'de', difficulty: 'silver', module: 4, content: {
      'from_name': 'Buchhaltung Müller',
      'from_email': 'rechnung@mueller-logistlk.test',
      'subject': 'Offene Rechnung',
      'time': '08:12',
      'body_md': 'Bitte zahlen Sie **innerhalb von 24 Stunden**.',
      'links': <Map<String, String>>[],
      'attachments': [
        {'name': 'Rechnung.pdf.exe', 'size_kb': 412}
      ],
    });

void main() {
  testWidgets('the real sender address only shows after tapping the sender', (tester) async {
    await tester.pumpWidget(_host(MailSim(s: _mail(), props: SimProps(onAction: (_) {}))));
    await tester.pumpAndSettle();
    expect(find.textContaining('mueller-logistlk'), findsNothing);
    await tester.tap(find.text('Buchhaltung Müller'));
    await tester.pumpAndSettle();
    expect(find.textContaining('mueller-logistlk'), findsOneWidget);
  });

  testWidgets('tapping the attachment and the report button send the right actions', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _mail(), props: SimProps(onAction: actions.add))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechnung.pdf.exe'));
    await tester.tap(find.text('Melden'));
    expect(actions, ['open_attachment', 'report']);
  });

  testWidgets('after the answer there are no more actions and the sender is visible', (tester) async {
    await tester.pumpWidget(_host(MailSim(s: _mail(), props: SimProps(reveal: [RedFlag('from_email', 'Hinweis')]))));
    await tester.pump();
    expect(find.text('Melden'), findsNothing);
    expect(find.textContaining('mueller-logistlk'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
  });

  testWidgets('spot-the-flags mode reports the tapped elements, including sentences', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(_host(MailSim(s: _mail(), props: SimProps(selected: const {}, onToggle: tapped.add))));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('mueller-logistlk'));
    await tester.tap(find.textContaining('innerhalb von 24 Stunden'));
    expect(tapped, ['from_email', 'body:Bitte zahlen Sie innerhalb von 24 Stunden.']);
  });

  test('sentences are split without losing text or markdown markers', () {
    expect(sentencesOf('Hallo,\n\nBitte **zahlen** Sie. Danke!'), ['Hallo,', 'Bitte zahlen Sie.', 'Danke!']);
    expect(sentencesOf('Gruß\nS. Müller'), ['Gruß', 'S. Müller']);
    expect(sentencesOf('Termin bei Dr. Lang. Bis bald'), ['Termin bei Dr. Lang.', 'Bis bald']);
  });
}
