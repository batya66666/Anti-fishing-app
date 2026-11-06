// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Fertig';

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get backHome => 'Zur Startseite';

  @override
  String get errorGeneric =>
      'Das hat nicht geklappt. Versuch es gleich noch einmal.';

  @override
  String get offlineBanner =>
      'Offline-Modus: Du spielst lokal, Fortschritt bleibt auf diesem Gerät.';

  @override
  String get hackedTitle => 'GEHACKT';

  @override
  String get hackedSubtitle => 'Ihre Dateien wurden verschlüsselt.';

  @override
  String get hackedPay =>
      'Zahlen Sie innerhalb von 72 Stunden, sonst werden alle Daten gelöscht.';

  @override
  String get calmTitle => 'Keine Sorge: Das war eine Übung.';

  @override
  String get calmBody =>
      'Im Ernstfall wäre jetzt die ganze Firma betroffen. Genau deshalb üben wir hier, wo es nichts kostet. Schauen wir, was dich hätte warnen können.';

  @override
  String get calmButton => 'Zeig mir, was ich übersehen habe';

  @override
  String get simToMe => 'an mich';

  @override
  String get actOk => 'In Ordnung';

  @override
  String get actReply => 'Antworten';

  @override
  String get actDelete => 'Löschen';

  @override
  String get actReport => 'Melden';

  @override
  String get actLeave => 'Verlassen';

  @override
  String get actOpen => 'Öffnen';

  @override
  String get linkPeekTitle => 'Dieser Link führt wirklich zu:';

  @override
  String get openLink => 'Trotzdem öffnen';

  @override
  String get simLoginTitle => 'Bitte melden Sie sich an';

  @override
  String get simUser => 'E-Mail oder Benutzername';

  @override
  String get simPassword => 'Passwort';

  @override
  String get simSignIn => 'Anmelden';

  @override
  String get callIncoming => 'Eingehender Anruf';

  @override
  String get callDecline => 'Ablehnen';

  @override
  String get callAccept => 'Annehmen';

  @override
  String get callYourAnswer => 'Deine Antwort:';

  @override
  String get qrLeadsTo => 'Der Code führt zu:';

  @override
  String get qrScan => 'Code scannen';

  @override
  String get qrOpen => 'Öffnen';

  @override
  String get qrIgnore => 'Nicht öffnen';

  @override
  String get pushApprove => 'Bestätigen';

  @override
  String get pushDeny => 'Ablehnen';

  @override
  String get fileDownloads => 'Downloads';

  @override
  String get fileDetails => 'Details anzeigen';

  @override
  String get fileRealName => 'Echter Dateiname';

  @override
  String get fileType => 'Typ';

  @override
  String get resultReported => 'Gemeldet! Angriff gestoppt.';

  @override
  String get resultWellDone => 'Gut erkannt!';

  @override
  String get resultGenuine => 'Richtig: Das war echt.';

  @override
  String get resultSafe => 'Nicht reingefallen, aber...';

  @override
  String get resultHacked => 'Du bist darauf reingefallen.';

  @override
  String get resultFalseAlarm => 'Fehlalarm: Das war echt.';

  @override
  String get resultMissed => 'Das war nicht die beste Reaktion.';

  @override
  String redFlagsTitle(Object count) {
    return '$count Warnzeichen';
  }

  @override
  String get lessonStart => 'Los geht\'s';

  @override
  String get reviewEmpty => 'Gerade ist nichts zu wiederholen. Stark!';

  @override
  String runDone(Object correct, Object total) {
    return '$correct von $total richtig';
  }

  @override
  String get onbTitle1 => 'Fünf Minuten am Tag';

  @override
  String get onbBody1 =>
      'Du arbeitest im Büro und dein Postfach läuft voll. Welche Nachricht ist echt, welche ein Angriff?';

  @override
  String get onbTitle2 => 'Fehler sind erlaubt';

  @override
  String get onbBody2 =>
      'Fällst du auf einen Köder herein, wirst du hier \"gehackt\". Das bleibt im Kopf, kostet aber nichts. Im echten Leben wäre es anders.';

  @override
  String get onbTitle3 => 'Melden gewinnt';

  @override
  String get onbBody3 =>
      'Nicht klicken ist gut. Melden ist besser. Tritt im Duell gegen andere an und werde vom Praktikanten zum CISO.';

  @override
  String get onbStart => 'Schicht beginnen';

  @override
  String get onbLanguage => 'Sprache';

  @override
  String get onbMode => 'Wie möchtest du üben?';

  @override
  String get modeOffice => 'Büro';

  @override
  String get modeOfficeBody => 'Ganze Schichten, Duelle, Ligen und Abzeichen';

  @override
  String get modeSimple => 'Einfacher Modus';

  @override
  String get modeSimpleBody =>
      'Große Schrift, kein Zeitdruck, keine Ranglisten: Betrug im Alltag erkennen';

  @override
  String get onbPrivacy =>
      'Kein Konto nötig. Du spielst anonym, deine Fehler sieht nur du.';

  @override
  String get tabWork => 'Arbeit';

  @override
  String get tabDuel => 'Duell';

  @override
  String get tabLeague => 'Liga';

  @override
  String get tabProfile => 'Profil';

  @override
  String levelLine(Object level, Object title) {
    return 'Level $level · $title';
  }

  @override
  String xpLine(Object xp, Object ceil) {
    return '$xp / $ceil XP';
  }

  @override
  String get shiftCardTitle => 'Deine Schicht beginnt';

  @override
  String get shiftCardBody =>
      'Im Postfach warten neue Nachrichten. Schütze die Firma.';

  @override
  String get shiftStart => 'Schicht starten';

  @override
  String get shiftDoneTitle => 'Feierabend!';

  @override
  String get shiftDoneBody =>
      'Gute Arbeit. Dein Kopf braucht jetzt eine Pause, morgen wartet ein neuer Fall. Heute geht noch ein Duell.';

  @override
  String reviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fehler warten auf eine Wiederholung',
      one: '1 Fehler wartet auf eine Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String get modeSwipe => 'Swipe';

  @override
  String swipeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heute noch $count Runden',
      one: 'Heute noch 1 Runde',
    );
    return '$_temp0';
  }

  @override
  String get modeFlags => 'Warnzeichen finden';

  @override
  String get modeFlagsSub => 'Tippe auf alles Verdächtige';

  @override
  String get modeCases => 'Case Files';

  @override
  String get modeCasesSub => 'Echte Angriffe nachspielen';

  @override
  String get modeRedTeam => 'Werde zum Hacker';

  @override
  String get modeRedTeamSub => 'Baue selbst einen Köder';

  @override
  String get checkTitle => 'Nachricht prüfen';

  @override
  String get checkTileSub =>
      'Hast du etwas Verdächtiges bekommen? Hier prüfen.';

  @override
  String get skillTree => 'Dein Lernpfad';

  @override
  String get skillTreeSub =>
      'Alle 13 Themen sind offen: Grundwissen ist immer kostenlos.';

  @override
  String get module1 => 'Grundlagen';

  @override
  String get module2 => 'Absender';

  @override
  String get module3 => 'Links & URLs';

  @override
  String get module4 => 'Anhänge';

  @override
  String get module5 => 'Rechnungen & CEO-Fraud';

  @override
  String get module6 => 'SMS & Messenger';

  @override
  String get module7 => 'Anrufe & Deepfakes';

  @override
  String get module8 => 'QR-Codes';

  @override
  String get module9 => 'Konten & Passwörter';

  @override
  String get module10 => 'Firmenlaptop';

  @override
  String get module11 => 'Soziale Netze';

  @override
  String get module12 => 'Vor Ort';

  @override
  String get module13 => 'Was tun, wenn geklickt?';

  @override
  String get tip1 =>
      'Betrüger greifen deine Gefühle an: Eile, Angst, Autorität, Neugier und Gier. Spürst du plötzlich Druck, ist genau das der Moment für eine Pause.';

  @override
  String get tip2 =>
      'Der angezeigte Name beweist nichts. Tippe auf den Absender und lies die echte Adresse. Achte auf vertauschte Buchstaben und fremde Domains.';

  @override
  String get tip3 =>
      'Lies eine Adresse von rechts nach links: Der Teil direkt vor dem ersten Schrägstrich entscheidet, wem die Seite gehört. Das Schloss heißt nur \"verschlüsselt\", nicht \"sicher\". Halte Links gedrückt, um das Ziel zu sehen.';

  @override
  String get tip4 =>
      'Rechnungen sind keine Programme. Vorsicht bei .exe, .lnk, .iso und Makro-Dateien wie .xlsm, außerdem bei doppelten Endungen und Archiven mit Passwort.';

  @override
  String get tip5 =>
      'Bankdaten ändern sich selten per E-Mail. Prüfe jede Änderung telefonisch unter der bekannten Nummer. Auch der Chef muss sich an das Vier-Augen-Prinzip halten.';

  @override
  String get tip6 =>
      'Paket, Bank, \"Hallo Mama\": Solche Nachrichten sollen dich zum Klicken oder Zahlen bringen. Öffne die App selbst oder ruf die bekannte Nummer an.';

  @override
  String get tip7 =>
      'Stimmen lassen sich mit wenigen Sekunden Audio klonen und Nummern im Display fälschen. Leg auf und ruf selbst über die bekannte Nummer zurück.';

  @override
  String get tip8 =>
      'Einem QR-Code siehst du das Ziel nicht an. Prüfe nach dem Scannen die Adresse und achte auf Aufkleber über dem Original.';

  @override
  String get tip9 =>
      'Für jeden Dienst ein eigenes Passwort, am besten aus einem Passwortmanager. Bestätige nie eine Anmeldung, die du nicht selbst gestartet hast.';

  @override
  String get tip10 =>
      'Der Firmenlaptop ist nur für die Arbeit da: keine Spiele, keine Mods, keine privaten Downloads. Öffentliches WLAN nur mit VPN. Beim Weggehen immer sperren.';

  @override
  String get tip11 =>
      'Angreifer lesen mit: Name, Abteilung und Systeme reichen für die perfekte Mail. Teile Erfolge, aber keine Details zu internen Abläufen.';

  @override
  String get tip12 =>
      'Warnweste und volle Hände öffnen viele Türen. Begleite Unbekannte freundlich zum Empfang. Fundstücke wie USB-Sticks gehören zur IT, nicht in den Rechner.';

  @override
  String get tip13 =>
      'Es kann jedem passieren. Trenne das Netzwerk und ruf sofort die IT an. Jede Minute zählt und niemand wird dich dafür verurteilen.';

  @override
  String get simpleWelcome => 'Schön, dass du da bist';

  @override
  String get simplePractice => 'Heute üben';

  @override
  String get simplePracticeBody => 'Ein paar Nachrichten in Ruhe ansehen';

  @override
  String get simplePracticeDone => 'Für heute geschafft. Bis morgen!';

  @override
  String get simpleReview => 'Wiederholen';

  @override
  String get simpleLearn => 'Betrug per SMS und Anruf';

  @override
  String get simpleLearnBody => 'Die häufigsten Maschen kennenlernen';

  @override
  String get simpleLeave => 'Zum Büro-Modus wechseln';

  @override
  String get shiftTitle => 'Heutige Schicht';

  @override
  String get shiftHint =>
      'Antworte auf alles, was reinkommt. Tipp: Absender antippen, Links gedrückt halten.';

  @override
  String get backToInbox => 'Zurück zum Postfach';

  @override
  String get shiftFinish => 'Schicht beenden';

  @override
  String get inboxCall => 'Eingehender Anruf';

  @override
  String get reportTitle => 'Schicht beendet';

  @override
  String reportProtected(Object good, Object total) {
    return 'Du hast die Firma $good von $total Mal richtig geschützt.';
  }

  @override
  String promotion(Object title) {
    return 'Beförderung! Du bist jetzt: $title';
  }

  @override
  String get streak => 'Serie';

  @override
  String get reportedShort => 'Gemeldet';

  @override
  String get reportMissed => 'Das nimmst du mit';

  @override
  String get reportWillReturn =>
      'Diese Fälle kommen in 1, 3 und 7 Tagen wieder, bis sie sitzen.';

  @override
  String get reportRest =>
      'Gute Schicht! Dein Kopf braucht jetzt Ruhe, morgen wartet ein neuer Fall.';

  @override
  String get swipeLimit =>
      'Für heute sind deine Swipe-Runden vorbei. Das Wiederholen deiner Fehler bleibt immer kostenlos.';

  @override
  String get swipePhishing => 'Phishing';

  @override
  String get swipeGenuine => 'Echt';

  @override
  String swipeResult(Object correct, Object total) {
    return '$correct von $total richtig';
  }

  @override
  String get flagsDone => 'Punkte für deine Spürnase';

  @override
  String get flagsHint =>
      'Tippe auf alles, was verdächtig wirkt, und prüfe dann.';

  @override
  String flagsSubmit(Object count) {
    return 'Prüfen ($count markiert)';
  }

  @override
  String flagsResult(Object found, Object total, Object wrong) {
    return '$found von $total gefunden, $wrong falsch markiert';
  }

  @override
  String get reviewTitle => 'Fehler wiederholen';

  @override
  String get duelTitle => 'PvP-Duell';

  @override
  String get duelSub => 'Gleiche Aufgaben, gleiche Zeit: Wer erkennt mehr?';

  @override
  String duelRecord(Object wins, Object losses) {
    return '$wins Siege · $losses Niederlagen';
  }

  @override
  String get duelFind => 'Gegner suchen';

  @override
  String get duelSearching => 'Suche Gegner...';

  @override
  String get duelFriendly => 'Gegen Freunde spielen';

  @override
  String get duelCreateCode => 'Code und QR erstellen';

  @override
  String get duelCodeHint => 'Code';

  @override
  String get duelJoin => 'Beitreten';

  @override
  String get duelVsBot => 'Gegen den Bot üben';

  @override
  String get duelBotShort => 'Gegen Bot';

  @override
  String get duelScanMe => 'Scannen und mitspielen';

  @override
  String get duelWaiting => 'Warte auf Gegner...';

  @override
  String get duelNeedsServer =>
      'Duelle mit Code brauchen eine Verbindung zum Server. Der Bot ist offline verfügbar.';

  @override
  String get duelBadCode =>
      'Diesen Code gibt es nicht oder das Duell läuft schon.';

  @override
  String get duelConnecting => 'Verbinde...';

  @override
  String get duelWaitingOpponent => 'Warte auf den Gegner...';

  @override
  String duelRound(Object round, Object total) {
    return 'Runde $round/$total';
  }

  @override
  String get duelBothDone => 'Beide haben geantwortet';

  @override
  String get duelWaitOther => 'Warte auf den Gegner';

  @override
  String get duelWrong => 'Daneben!';

  @override
  String get duelWasAttack => 'Das war ein Angriff.';

  @override
  String get duelWasGenuine => 'Das war echt.';

  @override
  String get duelWon => 'Gewonnen!';

  @override
  String get duelLost => 'Knapp daneben';

  @override
  String get duelDraw => 'Unentschieden';

  @override
  String get duelReview => 'Das nimmst du mit';

  @override
  String get casesIntro =>
      'Echte Vorfälle zum Nachspielen. An jedem Punkt kannst du den Angriff stoppen. Schaffst du, was damals niemand geschafft hat?';

  @override
  String get caseStopped => 'Angriff gestoppt!';

  @override
  String get caseContinues => 'Der Angriff läuft weiter...';

  @override
  String get caseWinTitle => 'Du hättest es verhindert.';

  @override
  String get caseLoseTitle => 'So ist es wirklich passiert.';

  @override
  String get caseReality => 'Was wirklich geschah';

  @override
  String get caseSources => 'Quellen';

  @override
  String get rtIntro =>
      'Du bist Pentester für eine fiktive Firma. Baue eine Mail und finde heraus, warum Köder funktionieren. Wer die Hebel kennt, erkennt sie.';

  @override
  String get rtSender => 'Absender';

  @override
  String get rtSenderUnknown => 'Unbekannt';

  @override
  String get rtSenderColleague => 'Kollegin';

  @override
  String get rtSenderIt => 'IT-Abteilung';

  @override
  String get rtSenderBoss => 'Chef';

  @override
  String get rtPretext => 'Anlass';

  @override
  String get rtPretextParcel => 'Paket';

  @override
  String get rtPretextPassword => 'Passwort läuft ab';

  @override
  String get rtPretextInvoice => 'Rechnung';

  @override
  String get rtPretextBonus => 'Bonus';

  @override
  String get rtUrgency => 'Dringlichkeit';

  @override
  String get rtUrgencyNone => 'Keine';

  @override
  String get rtUrgencyToday => 'Heute';

  @override
  String get rtUrgencyHour => '1 Stunde';

  @override
  String get rtPersonal => 'Persönlich';

  @override
  String get rtPersonalNone => 'Allgemein';

  @override
  String get rtPersonalName => 'Name';

  @override
  String get rtPersonalProject => 'Name + Projekt';

  @override
  String get rtBait => 'Köder';

  @override
  String get rtBaitLink => 'Link';

  @override
  String get rtBaitAttachment => 'Anhang';

  @override
  String get rtBaitQr => 'QR-Code';

  @override
  String get rtEthics =>
      'Alles bleibt im Spiel: feste Bausteine, fiktive Firma und Domains, kein Export. Diese Übung zeigt, wie Angriffe funktionieren, damit du sie erkennst.';

  @override
  String get rtLaunch => 'An 100 Kollegen senden';

  @override
  String get rtRunning => 'Die Kampagne läuft...';

  @override
  String get rtDone => 'Ergebnis der Kampagne';

  @override
  String get rtClicked => 'Geklickt';

  @override
  String get rtReported => 'Gemeldet';

  @override
  String get rtIgnored => 'Ignoriert';

  @override
  String get rtVerdictHigh => 'Erschreckend wirksam.';

  @override
  String get rtVerdictMid => 'Beachtlich: Das reicht für einen Einbruch.';

  @override
  String get rtVerdictLow => 'Die meisten durchschauen das.';

  @override
  String get rtLesson =>
      'Ein einziger Klick reicht Angreifern. Autorität, Zeitdruck und persönliche Details machen den Unterschied. Genau daran erkennst du Köder ab jetzt selbst. Und jede Meldung hilft: Die IT kann alle warnen, bevor der Nächste klickt.';

  @override
  String get rtAgain => 'Neue Kampagne';

  @override
  String get checkIntro =>
      'Füge den Text einer verdächtigen Nachricht ein oder lade einen Screenshot hoch.';

  @override
  String get checkHint => 'Text der Nachricht...';

  @override
  String get checkScreenshot => 'Screenshot';

  @override
  String get checkSample1 => 'Beispiel: Paket';

  @override
  String get checkSample1Text =>
      'Ihr Paket konnte nicht zugestellt werden. Zahlen Sie sofort 1,99 € Gebühr: paket-zustellung.xyz/x7';

  @override
  String get checkSample2 => 'Beispiel: Neue Nummer';

  @override
  String get checkSample2Text =>
      'Hallo Mama, das ist meine neue Nummer. Kannst du mir schnell Geld überweisen? Sag es niemandem!';

  @override
  String get checkButton => 'Jetzt prüfen';

  @override
  String get checkDangerous => 'Gefährlich';

  @override
  String get checkSuspicious => 'Verdächtig';

  @override
  String get checkUnclear => 'Keine klaren Warnzeichen';

  @override
  String checkRisk(Object score) {
    return 'Risiko $score von 100';
  }

  @override
  String get checkSourceAi => 'Analyse durch KI (Claude).';

  @override
  String get checkSourceRules =>
      'Analyse durch die lokale Regel-Prüfung, ohne KI.';

  @override
  String get checkDisclaimer =>
      'Eine Einschätzung, keine Garantie, und kein Ersatz für einen Virenscanner. Nachrichten werden nicht gespeichert. Entferne vor dem Hochladen persönliche Daten.';

  @override
  String get leagueTitle => 'Liga';

  @override
  String leagueTier(Object tier) {
    return '$tier-Liga';
  }

  @override
  String leagueSub(Object xp) {
    return '$xp XP diese Woche. Die Top 7 steigen am Sonntag auf.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silber';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamant';

  @override
  String get boardWeek => 'Woche';

  @override
  String get boardGlobal => 'Gesamt';

  @override
  String get boardCompany => 'Firma';

  @override
  String get boardEmpty => 'Noch niemand hier. Sei die erste Person!';

  @override
  String get boardPrivacy =>
      'Ranglisten zeigen nur Spitznamen. In den Einstellungen kannst du dich ausblenden.';

  @override
  String get statReporting => 'Melderate';

  @override
  String get statAccuracy => 'Trefferquote';

  @override
  String get statBestStreak => 'Beste Serie';

  @override
  String get statReported => 'Gemeldet';

  @override
  String get statHacked => 'Gehackt';

  @override
  String get statFalseAlarms => 'Fehlalarme';

  @override
  String get badges => 'Abzeichen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get badgeFirstShift => 'Erste Schicht';

  @override
  String get badgePerfectShift => 'Perfekte Schicht';

  @override
  String get badgeFirstReport => 'Erste Meldung';

  @override
  String get badgeReporter => '25 Meldungen';

  @override
  String get badgeCeo => 'Chef-resistent';

  @override
  String get badgeMfa => 'Eiserne Nerven';

  @override
  String get badgeMacro => 'Makrojäger';

  @override
  String get badgeHomoglyph => 'Adlerauge';

  @override
  String get badgeQr => 'QR-Skeptiker';

  @override
  String get badgeFirstDuel => 'Erstes Duell';

  @override
  String get badgeDuelWinner => 'Duellsieger';

  @override
  String get badgeStreak3 => '3 Tage Serie';

  @override
  String get badgeStreak7 => '7 Tage Serie';

  @override
  String get badgeHardWay => 'Daraus gelernt';

  @override
  String get renameTitle => 'Spitzname ändern';

  @override
  String get settingLanguage => 'Sprache';

  @override
  String get settingSound => 'Ton und Sprache';

  @override
  String get settingPublicBoard => 'In öffentlichen Ranglisten zeigen';

  @override
  String get settingExport => 'Meine Daten kopieren';

  @override
  String get settingExportSub =>
      'Alles, was wir über dich speichern, als JSON (DSGVO)';

  @override
  String get settingExportDone => 'Deine Daten liegen in der Zwischenablage.';

  @override
  String get settingDelete => 'Konto löschen';

  @override
  String get settingDeleteBody =>
      'Dein Fortschritt und alle Daten werden endgültig gelöscht.';

  @override
  String get settingDeleteConfirm => 'Endgültig löschen';

  @override
  String get settingDemoReset => 'Demo: Tag zurücksetzen';

  @override
  String get settingDemoResetSub =>
      'Heutige Schicht neu spielen, alle Wiederholungen fällig';

  @override
  String get settingDemoResetDone => 'Der Tag wurde zurückgesetzt.';

  @override
  String get premiumTitle => 'Tarife';

  @override
  String get premiumIntro =>
      'Der Schutz vor Betrug bleibt kostenlos. Unternehmen finanzieren die soziale Seite mit.';

  @override
  String get premiumB2bTitle => 'Für Unternehmen';

  @override
  String get premiumNote =>
      'Vorschau: In dieser Hackathon-Version ist noch keine Zahlung möglich. Preise sind Richtwerte.';

  @override
  String get pricePremium => '3,99 € / Monat';

  @override
  String get priceFamily => '5,99 € / Monat';

  @override
  String get priceTeam => '2–3 € pro Person / Monat';

  @override
  String get priceBusiness => '4–5 € pro Person / Monat';

  @override
  String get priceEnterprise => 'Individuell';

  @override
  String get planFree =>
      '1 Schicht pro Tag, Grundlagen, Fehler wiederholen, 1 Duell pro Tag, einfacher Modus';

  @override
  String get planPremium =>
      'Ohne Limits, alle Module, Case Files, Red Team, Nachrichten-Check ohne Limit, Serien einfrieren';

  @override
  String get planFamily => 'Bis zu 6 Personen: Schütze deine Eltern';

  @override
  String get planTeam =>
      'Firmenliga, Admin-Panel, Berichte nach Abteilung, keine Limits';

  @override
  String get planBusiness =>
      'Dazu eigene Szenarien, KI-Generator, SSO, Berichte für NIS2, ISO 27001 und TISAX';

  @override
  String get planEnterprise =>
      'Dazu Phishing-Übungen auf die echte Mail, Integrationen, SLA, EU-Hosting nach Wahl';

  @override
  String get adminTitle => 'KÖDER für Unternehmen';

  @override
  String get adminSubtitle => 'Human Risk Dashboard';

  @override
  String get adminEmail => 'E-Mail';

  @override
  String get adminPassword => 'Passwort';

  @override
  String get adminSignIn => 'Anmelden';

  @override
  String get adminBadLogin => 'E-Mail oder Passwort stimmen nicht.';

  @override
  String get adminLive => 'Live';

  @override
  String get adminTabDashboard => 'Dashboard';

  @override
  String get adminTabScenarios => 'Szenarien';

  @override
  String get adminTabJury => 'QR für alle';

  @override
  String get adminDemoData =>
      'Demo-Unternehmen: Der Verlauf ist synthetisch. Antworten aus der App kommen live dazu.';

  @override
  String get adminReport => 'Bericht für Audit (PDF)';

  @override
  String get adminRisk => 'Human Risk Score';

  @override
  String get riskLow => 'Gering';

  @override
  String get riskMedium => 'Mittel';

  @override
  String get riskHigh => 'Hoch';

  @override
  String get adminReportingRate => 'Melderate';

  @override
  String get adminReportingHint => 'Angriffe, die an die IT gingen';

  @override
  String get adminClickRate => 'Klickrate';

  @override
  String get adminClickHint => 'Angriffe, die erfolgreich waren';

  @override
  String get adminDecisions => 'Entscheidungen';

  @override
  String get adminDecisionsHint => 'In den letzten 10 Wochen';

  @override
  String get adminHeatmap => 'Wo braucht es Training?';

  @override
  String get adminHeatmapSub =>
      'Risiko nach Abteilung und Angriffsart, 0 bis 100';

  @override
  String get adminLegendLow => 'geringes Risiko';

  @override
  String get adminLegendHigh => 'hohes Risiko';

  @override
  String adminHidden(Object names) {
    return 'Nicht ausgewiesen, weil zu klein: $names';
  }

  @override
  String get adminDepartments => 'Abteilungen';

  @override
  String get adminColDepartment => 'Abteilung';

  @override
  String get adminColSize => 'Größe';

  @override
  String get adminColRisk => 'Risiko';

  @override
  String get adminColReporting => 'Melderate';

  @override
  String get adminTooSmall => 'zu klein zum Anzeigen';

  @override
  String get adminTrendRisk => 'Risiko im Verlauf';

  @override
  String get adminTrendRiskSub => 'Human Risk Score pro Woche';

  @override
  String get adminTrendReporting => 'Melderate im Verlauf';

  @override
  String get adminTrendReportingSub => 'Prozent der Angriffe pro Woche';

  @override
  String get adminFeed => 'Gerade passiert';

  @override
  String get adminFeedSub => 'Nur Abteilungen, niemals Namen';

  @override
  String get adminFeedEmpty => 'Sobald jemand spielt, erscheint es hier.';

  @override
  String adminFeedLine(Object department, Object event, Object attack) {
    return '$department: $event ($attack)';
  }

  @override
  String get feedReported => 'Angriff gemeldet';

  @override
  String get feedHacked => 'auf Angriff hereingefallen';

  @override
  String get feedHandled => 'richtig reagiert';

  @override
  String get feedMissed => 'nicht optimal reagiert';

  @override
  String adminPrivacy(Object min) {
    return 'Datenschutz: Die Statistik wird ohne Personenbezug gespeichert. Abteilungen unter $min Personen werden nicht ausgewiesen. So wird das Training zum Lernen und nicht zur Überwachung.';
  }

  @override
  String get attackInvoice => 'Rechnungs-betrug';

  @override
  String get attackCredentials => 'Passwort-Phishing';

  @override
  String get attackCeo => 'CEO-Fraud';

  @override
  String get attackAttachment => 'Anhänge';

  @override
  String get attackSmishing => 'SMS';

  @override
  String get attackVishing => 'Anrufe';

  @override
  String get attackQuishing => 'QR-Codes';

  @override
  String get attackMfa => 'MFA-Fatigue';

  @override
  String get attackLegit => 'echte Nachricht';

  @override
  String get attackOther => 'weitere Angriffe';

  @override
  String get genTitle => 'Szenarien für Ihre Firma';

  @override
  String get genIntro =>
      'Beschreiben Sie Ihr Unternehmen und erhalten Sie passende Übungen. Alles bleibt Entwurf, bis Sie es freigeben.';

  @override
  String get genCompany => 'Firma';

  @override
  String get genIndustry => 'Branche';

  @override
  String get genTools => 'Eingesetzte Systeme';

  @override
  String get genPartners => 'Lieferanten und Partner';

  @override
  String get genButton => 'Szenarien erzeugen';

  @override
  String get genSourceAi =>
      'Erzeugt von KI (Claude). Bitte vor der Freigabe prüfen.';

  @override
  String get genSourceTemplate =>
      'Aus Vorlagen erzeugt: Für KI-Texte muss ein API-Schlüssel gesetzt sein.';

  @override
  String get genAttack => 'Angriff';

  @override
  String get genGenuine => 'Echt';

  @override
  String get genPublish => 'Freigeben';

  @override
  String get genPublished => 'Freigegeben';

  @override
  String get juryTitle => 'Spielen Sie gegen uns!';

  @override
  String get jurySub =>
      'Scannen, und in Sekunden sind Sie im Duell. Ohne App und ohne Konto.';
}
