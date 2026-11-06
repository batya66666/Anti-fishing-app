import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get finish;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @backHome.
  ///
  /// In de, this message translates to:
  /// **'Zur Startseite'**
  String get backHome;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt. Versuch es gleich noch einmal.'**
  String get errorGeneric;

  /// No description provided for @offlineBanner.
  ///
  /// In de, this message translates to:
  /// **'Offline-Modus: Du spielst lokal, Fortschritt bleibt auf diesem Gerät.'**
  String get offlineBanner;

  /// No description provided for @hackedTitle.
  ///
  /// In de, this message translates to:
  /// **'GEHACKT'**
  String get hackedTitle;

  /// No description provided for @hackedSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ihre Dateien wurden verschlüsselt.'**
  String get hackedSubtitle;

  /// No description provided for @hackedPay.
  ///
  /// In de, this message translates to:
  /// **'Zahlen Sie innerhalb von 72 Stunden, sonst werden alle Daten gelöscht.'**
  String get hackedPay;

  /// No description provided for @calmTitle.
  ///
  /// In de, this message translates to:
  /// **'Keine Sorge: Das war eine Übung.'**
  String get calmTitle;

  /// No description provided for @calmBody.
  ///
  /// In de, this message translates to:
  /// **'Im Ernstfall wäre jetzt die ganze Firma betroffen. Genau deshalb üben wir hier, wo es nichts kostet. Schauen wir, was dich hätte warnen können.'**
  String get calmBody;

  /// No description provided for @calmButton.
  ///
  /// In de, this message translates to:
  /// **'Zeig mir, was ich übersehen habe'**
  String get calmButton;

  /// No description provided for @simToMe.
  ///
  /// In de, this message translates to:
  /// **'an mich'**
  String get simToMe;

  /// No description provided for @actOk.
  ///
  /// In de, this message translates to:
  /// **'In Ordnung'**
  String get actOk;

  /// No description provided for @actReply.
  ///
  /// In de, this message translates to:
  /// **'Antworten'**
  String get actReply;

  /// No description provided for @actDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get actDelete;

  /// No description provided for @actReport.
  ///
  /// In de, this message translates to:
  /// **'Melden'**
  String get actReport;

  /// No description provided for @actLeave.
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get actLeave;

  /// No description provided for @actOpen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get actOpen;

  /// No description provided for @linkPeekTitle.
  ///
  /// In de, this message translates to:
  /// **'Dieser Link führt wirklich zu:'**
  String get linkPeekTitle;

  /// No description provided for @openLink.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem öffnen'**
  String get openLink;

  /// No description provided for @simLoginTitle.
  ///
  /// In de, this message translates to:
  /// **'Bitte melden Sie sich an'**
  String get simLoginTitle;

  /// No description provided for @simUser.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Benutzername'**
  String get simUser;

  /// No description provided for @simPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get simPassword;

  /// No description provided for @simSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get simSignIn;

  /// No description provided for @callIncoming.
  ///
  /// In de, this message translates to:
  /// **'Eingehender Anruf'**
  String get callIncoming;

  /// No description provided for @callDecline.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get callDecline;

  /// No description provided for @callAccept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get callAccept;

  /// No description provided for @callYourAnswer.
  ///
  /// In de, this message translates to:
  /// **'Deine Antwort:'**
  String get callYourAnswer;

  /// No description provided for @qrLeadsTo.
  ///
  /// In de, this message translates to:
  /// **'Der Code führt zu:'**
  String get qrLeadsTo;

  /// No description provided for @qrScan.
  ///
  /// In de, this message translates to:
  /// **'Code scannen'**
  String get qrScan;

  /// No description provided for @qrOpen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get qrOpen;

  /// No description provided for @qrIgnore.
  ///
  /// In de, this message translates to:
  /// **'Nicht öffnen'**
  String get qrIgnore;

  /// No description provided for @pushApprove.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get pushApprove;

  /// No description provided for @pushDeny.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get pushDeny;

  /// No description provided for @fileDownloads.
  ///
  /// In de, this message translates to:
  /// **'Downloads'**
  String get fileDownloads;

  /// No description provided for @fileDetails.
  ///
  /// In de, this message translates to:
  /// **'Details anzeigen'**
  String get fileDetails;

  /// No description provided for @fileRealName.
  ///
  /// In de, this message translates to:
  /// **'Echter Dateiname'**
  String get fileRealName;

  /// No description provided for @fileType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get fileType;

  /// No description provided for @resultReported.
  ///
  /// In de, this message translates to:
  /// **'Gemeldet! Angriff gestoppt.'**
  String get resultReported;

  /// No description provided for @resultWellDone.
  ///
  /// In de, this message translates to:
  /// **'Gut erkannt!'**
  String get resultWellDone;

  /// No description provided for @resultGenuine.
  ///
  /// In de, this message translates to:
  /// **'Richtig: Das war echt.'**
  String get resultGenuine;

  /// No description provided for @resultSafe.
  ///
  /// In de, this message translates to:
  /// **'Nicht reingefallen, aber...'**
  String get resultSafe;

  /// No description provided for @resultHacked.
  ///
  /// In de, this message translates to:
  /// **'Du bist darauf reingefallen.'**
  String get resultHacked;

  /// No description provided for @resultFalseAlarm.
  ///
  /// In de, this message translates to:
  /// **'Fehlalarm: Das war echt.'**
  String get resultFalseAlarm;

  /// No description provided for @resultMissed.
  ///
  /// In de, this message translates to:
  /// **'Das war nicht die beste Reaktion.'**
  String get resultMissed;

  /// No description provided for @redFlagsTitle.
  ///
  /// In de, this message translates to:
  /// **'{count} Warnzeichen'**
  String redFlagsTitle(Object count);

  /// No description provided for @lessonStart.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get lessonStart;

  /// No description provided for @reviewEmpty.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist nichts zu wiederholen. Stark!'**
  String get reviewEmpty;

  /// No description provided for @runDone.
  ///
  /// In de, this message translates to:
  /// **'{correct} von {total} richtig'**
  String runDone(Object correct, Object total);

  /// No description provided for @onbTitle1.
  ///
  /// In de, this message translates to:
  /// **'Fünf Minuten am Tag'**
  String get onbTitle1;

  /// No description provided for @onbBody1.
  ///
  /// In de, this message translates to:
  /// **'Du arbeitest im Büro und dein Postfach läuft voll. Welche Nachricht ist echt, welche ein Angriff?'**
  String get onbBody1;

  /// No description provided for @onbTitle2.
  ///
  /// In de, this message translates to:
  /// **'Fehler sind erlaubt'**
  String get onbTitle2;

  /// No description provided for @onbBody2.
  ///
  /// In de, this message translates to:
  /// **'Fällst du auf einen Köder herein, wirst du hier \"gehackt\". Das bleibt im Kopf, kostet aber nichts. Im echten Leben wäre es anders.'**
  String get onbBody2;

  /// No description provided for @onbTitle3.
  ///
  /// In de, this message translates to:
  /// **'Melden gewinnt'**
  String get onbTitle3;

  /// No description provided for @onbBody3.
  ///
  /// In de, this message translates to:
  /// **'Nicht klicken ist gut. Melden ist besser. Tritt im Duell gegen andere an und werde vom Praktikanten zum CISO.'**
  String get onbBody3;

  /// No description provided for @onbStart.
  ///
  /// In de, this message translates to:
  /// **'Schicht beginnen'**
  String get onbStart;

  /// No description provided for @onbLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get onbLanguage;

  /// No description provided for @onbMode.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du üben?'**
  String get onbMode;

  /// No description provided for @modeOffice.
  ///
  /// In de, this message translates to:
  /// **'Büro'**
  String get modeOffice;

  /// No description provided for @modeOfficeBody.
  ///
  /// In de, this message translates to:
  /// **'Ganze Schichten, Duelle, Ligen und Abzeichen'**
  String get modeOfficeBody;

  /// No description provided for @modeSimple.
  ///
  /// In de, this message translates to:
  /// **'Einfacher Modus'**
  String get modeSimple;

  /// No description provided for @modeSimpleBody.
  ///
  /// In de, this message translates to:
  /// **'Große Schrift, kein Zeitdruck, keine Ranglisten: Betrug im Alltag erkennen'**
  String get modeSimpleBody;

  /// No description provided for @onbPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Kein Konto nötig. Du spielst anonym, deine Fehler sieht nur du.'**
  String get onbPrivacy;

  /// No description provided for @tabWork.
  ///
  /// In de, this message translates to:
  /// **'Arbeit'**
  String get tabWork;

  /// No description provided for @tabDuel.
  ///
  /// In de, this message translates to:
  /// **'Duell'**
  String get tabDuel;

  /// No description provided for @tabLeague.
  ///
  /// In de, this message translates to:
  /// **'Liga'**
  String get tabLeague;

  /// No description provided for @tabProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @levelLine.
  ///
  /// In de, this message translates to:
  /// **'Level {level} · {title}'**
  String levelLine(Object level, Object title);

  /// No description provided for @xpLine.
  ///
  /// In de, this message translates to:
  /// **'{xp} / {ceil} XP'**
  String xpLine(Object xp, Object ceil);

  /// No description provided for @shiftCardTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Schicht beginnt'**
  String get shiftCardTitle;

  /// No description provided for @shiftCardBody.
  ///
  /// In de, this message translates to:
  /// **'Im Postfach warten neue Nachrichten. Schütze die Firma.'**
  String get shiftCardBody;

  /// No description provided for @shiftStart.
  ///
  /// In de, this message translates to:
  /// **'Schicht starten'**
  String get shiftStart;

  /// No description provided for @shiftDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Feierabend!'**
  String get shiftDoneTitle;

  /// No description provided for @shiftDoneBody.
  ///
  /// In de, this message translates to:
  /// **'Gute Arbeit. Dein Kopf braucht jetzt eine Pause, morgen wartet ein neuer Fall. Heute geht noch ein Duell.'**
  String get shiftDoneBody;

  /// No description provided for @reviewDue.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Fehler wartet auf eine Wiederholung} other{{count} Fehler warten auf eine Wiederholung}}'**
  String reviewDue(int count);

  /// No description provided for @modeSwipe.
  ///
  /// In de, this message translates to:
  /// **'Swipe'**
  String get modeSwipe;

  /// No description provided for @swipeLeft.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Heute noch 1 Runde} other{Heute noch {count} Runden}}'**
  String swipeLeft(int count);

  /// No description provided for @modeFlags.
  ///
  /// In de, this message translates to:
  /// **'Warnzeichen finden'**
  String get modeFlags;

  /// No description provided for @modeFlagsSub.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf alles Verdächtige'**
  String get modeFlagsSub;

  /// No description provided for @modeCases.
  ///
  /// In de, this message translates to:
  /// **'Case Files'**
  String get modeCases;

  /// No description provided for @modeCasesSub.
  ///
  /// In de, this message translates to:
  /// **'Echte Angriffe nachspielen'**
  String get modeCasesSub;

  /// No description provided for @modeRedTeam.
  ///
  /// In de, this message translates to:
  /// **'Werde zum Hacker'**
  String get modeRedTeam;

  /// No description provided for @modeRedTeamSub.
  ///
  /// In de, this message translates to:
  /// **'Baue selbst einen Köder'**
  String get modeRedTeamSub;

  /// No description provided for @checkTitle.
  ///
  /// In de, this message translates to:
  /// **'Nachricht prüfen'**
  String get checkTitle;

  /// No description provided for @checkTileSub.
  ///
  /// In de, this message translates to:
  /// **'Hast du etwas Verdächtiges bekommen? Hier prüfen.'**
  String get checkTileSub;

  /// No description provided for @skillTree.
  ///
  /// In de, this message translates to:
  /// **'Dein Lernpfad'**
  String get skillTree;

  /// No description provided for @skillTreeSub.
  ///
  /// In de, this message translates to:
  /// **'Alle 13 Themen sind offen: Grundwissen ist immer kostenlos.'**
  String get skillTreeSub;

  /// No description provided for @module1.
  ///
  /// In de, this message translates to:
  /// **'Grundlagen'**
  String get module1;

  /// No description provided for @module2.
  ///
  /// In de, this message translates to:
  /// **'Absender'**
  String get module2;

  /// No description provided for @module3.
  ///
  /// In de, this message translates to:
  /// **'Links & URLs'**
  String get module3;

  /// No description provided for @module4.
  ///
  /// In de, this message translates to:
  /// **'Anhänge'**
  String get module4;

  /// No description provided for @module5.
  ///
  /// In de, this message translates to:
  /// **'Rechnungen & CEO-Fraud'**
  String get module5;

  /// No description provided for @module6.
  ///
  /// In de, this message translates to:
  /// **'SMS & Messenger'**
  String get module6;

  /// No description provided for @module7.
  ///
  /// In de, this message translates to:
  /// **'Anrufe & Deepfakes'**
  String get module7;

  /// No description provided for @module8.
  ///
  /// In de, this message translates to:
  /// **'QR-Codes'**
  String get module8;

  /// No description provided for @module9.
  ///
  /// In de, this message translates to:
  /// **'Konten & Passwörter'**
  String get module9;

  /// No description provided for @module10.
  ///
  /// In de, this message translates to:
  /// **'Firmenlaptop'**
  String get module10;

  /// No description provided for @module11.
  ///
  /// In de, this message translates to:
  /// **'Soziale Netze'**
  String get module11;

  /// No description provided for @module12.
  ///
  /// In de, this message translates to:
  /// **'Vor Ort'**
  String get module12;

  /// No description provided for @module13.
  ///
  /// In de, this message translates to:
  /// **'Was tun, wenn geklickt?'**
  String get module13;

  /// No description provided for @tip1.
  ///
  /// In de, this message translates to:
  /// **'Betrüger greifen deine Gefühle an: Eile, Angst, Autorität, Neugier und Gier. Spürst du plötzlich Druck, ist genau das der Moment für eine Pause.'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In de, this message translates to:
  /// **'Der angezeigte Name beweist nichts. Tippe auf den Absender und lies die echte Adresse. Achte auf vertauschte Buchstaben und fremde Domains.'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In de, this message translates to:
  /// **'Lies eine Adresse von rechts nach links: Der Teil direkt vor dem ersten Schrägstrich entscheidet, wem die Seite gehört. Das Schloss heißt nur \"verschlüsselt\", nicht \"sicher\". Halte Links gedrückt, um das Ziel zu sehen.'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In de, this message translates to:
  /// **'Rechnungen sind keine Programme. Vorsicht bei .exe, .lnk, .iso und Makro-Dateien wie .xlsm, außerdem bei doppelten Endungen und Archiven mit Passwort.'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In de, this message translates to:
  /// **'Bankdaten ändern sich selten per E-Mail. Prüfe jede Änderung telefonisch unter der bekannten Nummer. Auch der Chef muss sich an das Vier-Augen-Prinzip halten.'**
  String get tip5;

  /// No description provided for @tip6.
  ///
  /// In de, this message translates to:
  /// **'Paket, Bank, \"Hallo Mama\": Solche Nachrichten sollen dich zum Klicken oder Zahlen bringen. Öffne die App selbst oder ruf die bekannte Nummer an.'**
  String get tip6;

  /// No description provided for @tip7.
  ///
  /// In de, this message translates to:
  /// **'Stimmen lassen sich mit wenigen Sekunden Audio klonen und Nummern im Display fälschen. Leg auf und ruf selbst über die bekannte Nummer zurück.'**
  String get tip7;

  /// No description provided for @tip8.
  ///
  /// In de, this message translates to:
  /// **'Einem QR-Code siehst du das Ziel nicht an. Prüfe nach dem Scannen die Adresse und achte auf Aufkleber über dem Original.'**
  String get tip8;

  /// No description provided for @tip9.
  ///
  /// In de, this message translates to:
  /// **'Für jeden Dienst ein eigenes Passwort, am besten aus einem Passwortmanager. Bestätige nie eine Anmeldung, die du nicht selbst gestartet hast.'**
  String get tip9;

  /// No description provided for @tip10.
  ///
  /// In de, this message translates to:
  /// **'Der Firmenlaptop ist nur für die Arbeit da: keine Spiele, keine Mods, keine privaten Downloads. Öffentliches WLAN nur mit VPN. Beim Weggehen immer sperren.'**
  String get tip10;

  /// No description provided for @tip11.
  ///
  /// In de, this message translates to:
  /// **'Angreifer lesen mit: Name, Abteilung und Systeme reichen für die perfekte Mail. Teile Erfolge, aber keine Details zu internen Abläufen.'**
  String get tip11;

  /// No description provided for @tip12.
  ///
  /// In de, this message translates to:
  /// **'Warnweste und volle Hände öffnen viele Türen. Begleite Unbekannte freundlich zum Empfang. Fundstücke wie USB-Sticks gehören zur IT, nicht in den Rechner.'**
  String get tip12;

  /// No description provided for @tip13.
  ///
  /// In de, this message translates to:
  /// **'Es kann jedem passieren. Trenne das Netzwerk und ruf sofort die IT an. Jede Minute zählt und niemand wird dich dafür verurteilen.'**
  String get tip13;

  /// No description provided for @simpleWelcome.
  ///
  /// In de, this message translates to:
  /// **'Schön, dass du da bist'**
  String get simpleWelcome;

  /// No description provided for @simplePractice.
  ///
  /// In de, this message translates to:
  /// **'Heute üben'**
  String get simplePractice;

  /// No description provided for @simplePracticeBody.
  ///
  /// In de, this message translates to:
  /// **'Ein paar Nachrichten in Ruhe ansehen'**
  String get simplePracticeBody;

  /// No description provided for @simplePracticeDone.
  ///
  /// In de, this message translates to:
  /// **'Für heute geschafft. Bis morgen!'**
  String get simplePracticeDone;

  /// No description provided for @simpleReview.
  ///
  /// In de, this message translates to:
  /// **'Wiederholen'**
  String get simpleReview;

  /// No description provided for @simpleLearn.
  ///
  /// In de, this message translates to:
  /// **'Betrug per SMS und Anruf'**
  String get simpleLearn;

  /// No description provided for @simpleLearnBody.
  ///
  /// In de, this message translates to:
  /// **'Die häufigsten Maschen kennenlernen'**
  String get simpleLearnBody;

  /// No description provided for @simpleLeave.
  ///
  /// In de, this message translates to:
  /// **'Zum Büro-Modus wechseln'**
  String get simpleLeave;

  /// No description provided for @shiftTitle.
  ///
  /// In de, this message translates to:
  /// **'Heutige Schicht'**
  String get shiftTitle;

  /// No description provided for @shiftHint.
  ///
  /// In de, this message translates to:
  /// **'Antworte auf alles, was reinkommt. Tipp: Absender antippen, Links gedrückt halten.'**
  String get shiftHint;

  /// No description provided for @backToInbox.
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Postfach'**
  String get backToInbox;

  /// No description provided for @shiftFinish.
  ///
  /// In de, this message translates to:
  /// **'Schicht beenden'**
  String get shiftFinish;

  /// No description provided for @inboxCall.
  ///
  /// In de, this message translates to:
  /// **'Eingehender Anruf'**
  String get inboxCall;

  /// No description provided for @reportTitle.
  ///
  /// In de, this message translates to:
  /// **'Schicht beendet'**
  String get reportTitle;

  /// No description provided for @reportProtected.
  ///
  /// In de, this message translates to:
  /// **'Du hast die Firma {good} von {total} Mal richtig geschützt.'**
  String reportProtected(Object good, Object total);

  /// No description provided for @promotion.
  ///
  /// In de, this message translates to:
  /// **'Beförderung! Du bist jetzt: {title}'**
  String promotion(Object title);

  /// No description provided for @streak.
  ///
  /// In de, this message translates to:
  /// **'Serie'**
  String get streak;

  /// No description provided for @reportedShort.
  ///
  /// In de, this message translates to:
  /// **'Gemeldet'**
  String get reportedShort;

  /// No description provided for @reportMissed.
  ///
  /// In de, this message translates to:
  /// **'Das nimmst du mit'**
  String get reportMissed;

  /// No description provided for @reportWillReturn.
  ///
  /// In de, this message translates to:
  /// **'Diese Fälle kommen in 1, 3 und 7 Tagen wieder, bis sie sitzen.'**
  String get reportWillReturn;

  /// No description provided for @reportRest.
  ///
  /// In de, this message translates to:
  /// **'Gute Schicht! Dein Kopf braucht jetzt Ruhe, morgen wartet ein neuer Fall.'**
  String get reportRest;

  /// No description provided for @swipeLimit.
  ///
  /// In de, this message translates to:
  /// **'Für heute sind deine Swipe-Runden vorbei. Das Wiederholen deiner Fehler bleibt immer kostenlos.'**
  String get swipeLimit;

  /// No description provided for @swipePhishing.
  ///
  /// In de, this message translates to:
  /// **'Phishing'**
  String get swipePhishing;

  /// No description provided for @swipeGenuine.
  ///
  /// In de, this message translates to:
  /// **'Echt'**
  String get swipeGenuine;

  /// No description provided for @swipeResult.
  ///
  /// In de, this message translates to:
  /// **'{correct} von {total} richtig'**
  String swipeResult(Object correct, Object total);

  /// No description provided for @flagsDone.
  ///
  /// In de, this message translates to:
  /// **'Punkte für deine Spürnase'**
  String get flagsDone;

  /// No description provided for @flagsHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf alles, was verdächtig wirkt, und prüfe dann.'**
  String get flagsHint;

  /// No description provided for @flagsSubmit.
  ///
  /// In de, this message translates to:
  /// **'Prüfen ({count} markiert)'**
  String flagsSubmit(Object count);

  /// No description provided for @flagsResult.
  ///
  /// In de, this message translates to:
  /// **'{found} von {total} gefunden, {wrong} falsch markiert'**
  String flagsResult(Object found, Object total, Object wrong);

  /// No description provided for @reviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Fehler wiederholen'**
  String get reviewTitle;

  /// No description provided for @duelTitle.
  ///
  /// In de, this message translates to:
  /// **'PvP-Duell'**
  String get duelTitle;

  /// No description provided for @duelSub.
  ///
  /// In de, this message translates to:
  /// **'Gleiche Aufgaben, gleiche Zeit: Wer erkennt mehr?'**
  String get duelSub;

  /// No description provided for @duelRecord.
  ///
  /// In de, this message translates to:
  /// **'{wins} Siege · {losses} Niederlagen'**
  String duelRecord(Object wins, Object losses);

  /// No description provided for @duelFind.
  ///
  /// In de, this message translates to:
  /// **'Gegner suchen'**
  String get duelFind;

  /// No description provided for @duelSearching.
  ///
  /// In de, this message translates to:
  /// **'Suche Gegner...'**
  String get duelSearching;

  /// No description provided for @duelFriendly.
  ///
  /// In de, this message translates to:
  /// **'Gegen Freunde spielen'**
  String get duelFriendly;

  /// No description provided for @duelCreateCode.
  ///
  /// In de, this message translates to:
  /// **'Code und QR erstellen'**
  String get duelCreateCode;

  /// No description provided for @duelCodeHint.
  ///
  /// In de, this message translates to:
  /// **'Code'**
  String get duelCodeHint;

  /// No description provided for @duelJoin.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get duelJoin;

  /// No description provided for @duelVsBot.
  ///
  /// In de, this message translates to:
  /// **'Gegen den Bot üben'**
  String get duelVsBot;

  /// No description provided for @duelBotShort.
  ///
  /// In de, this message translates to:
  /// **'Gegen Bot'**
  String get duelBotShort;

  /// No description provided for @duelScanMe.
  ///
  /// In de, this message translates to:
  /// **'Scannen und mitspielen'**
  String get duelScanMe;

  /// No description provided for @duelWaiting.
  ///
  /// In de, this message translates to:
  /// **'Warte auf Gegner...'**
  String get duelWaiting;

  /// No description provided for @duelNeedsServer.
  ///
  /// In de, this message translates to:
  /// **'Duelle mit Code brauchen eine Verbindung zum Server. Der Bot ist offline verfügbar.'**
  String get duelNeedsServer;

  /// No description provided for @duelBadCode.
  ///
  /// In de, this message translates to:
  /// **'Diesen Code gibt es nicht oder das Duell läuft schon.'**
  String get duelBadCode;

  /// No description provided for @duelConnecting.
  ///
  /// In de, this message translates to:
  /// **'Verbinde...'**
  String get duelConnecting;

  /// No description provided for @duelWaitingOpponent.
  ///
  /// In de, this message translates to:
  /// **'Warte auf den Gegner...'**
  String get duelWaitingOpponent;

  /// No description provided for @duelRound.
  ///
  /// In de, this message translates to:
  /// **'Runde {round}/{total}'**
  String duelRound(Object round, Object total);

  /// No description provided for @duelBothDone.
  ///
  /// In de, this message translates to:
  /// **'Beide haben geantwortet'**
  String get duelBothDone;

  /// No description provided for @duelWaitOther.
  ///
  /// In de, this message translates to:
  /// **'Warte auf den Gegner'**
  String get duelWaitOther;

  /// No description provided for @duelWrong.
  ///
  /// In de, this message translates to:
  /// **'Daneben!'**
  String get duelWrong;

  /// No description provided for @duelWasAttack.
  ///
  /// In de, this message translates to:
  /// **'Das war ein Angriff.'**
  String get duelWasAttack;

  /// No description provided for @duelWasGenuine.
  ///
  /// In de, this message translates to:
  /// **'Das war echt.'**
  String get duelWasGenuine;

  /// No description provided for @duelWon.
  ///
  /// In de, this message translates to:
  /// **'Gewonnen!'**
  String get duelWon;

  /// No description provided for @duelLost.
  ///
  /// In de, this message translates to:
  /// **'Knapp daneben'**
  String get duelLost;

  /// No description provided for @duelDraw.
  ///
  /// In de, this message translates to:
  /// **'Unentschieden'**
  String get duelDraw;

  /// No description provided for @duelReview.
  ///
  /// In de, this message translates to:
  /// **'Das nimmst du mit'**
  String get duelReview;

  /// No description provided for @casesIntro.
  ///
  /// In de, this message translates to:
  /// **'Echte Vorfälle zum Nachspielen. An jedem Punkt kannst du den Angriff stoppen. Schaffst du, was damals niemand geschafft hat?'**
  String get casesIntro;

  /// No description provided for @caseStopped.
  ///
  /// In de, this message translates to:
  /// **'Angriff gestoppt!'**
  String get caseStopped;

  /// No description provided for @caseContinues.
  ///
  /// In de, this message translates to:
  /// **'Der Angriff läuft weiter...'**
  String get caseContinues;

  /// No description provided for @caseWinTitle.
  ///
  /// In de, this message translates to:
  /// **'Du hättest es verhindert.'**
  String get caseWinTitle;

  /// No description provided for @caseLoseTitle.
  ///
  /// In de, this message translates to:
  /// **'So ist es wirklich passiert.'**
  String get caseLoseTitle;

  /// No description provided for @caseReality.
  ///
  /// In de, this message translates to:
  /// **'Was wirklich geschah'**
  String get caseReality;

  /// No description provided for @caseSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get caseSources;

  /// No description provided for @rtIntro.
  ///
  /// In de, this message translates to:
  /// **'Du bist Pentester für eine fiktive Firma. Baue eine Mail und finde heraus, warum Köder funktionieren. Wer die Hebel kennt, erkennt sie.'**
  String get rtIntro;

  /// No description provided for @rtSender.
  ///
  /// In de, this message translates to:
  /// **'Absender'**
  String get rtSender;

  /// No description provided for @rtSenderUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get rtSenderUnknown;

  /// No description provided for @rtSenderColleague.
  ///
  /// In de, this message translates to:
  /// **'Kollegin'**
  String get rtSenderColleague;

  /// No description provided for @rtSenderIt.
  ///
  /// In de, this message translates to:
  /// **'IT-Abteilung'**
  String get rtSenderIt;

  /// No description provided for @rtSenderBoss.
  ///
  /// In de, this message translates to:
  /// **'Chef'**
  String get rtSenderBoss;

  /// No description provided for @rtPretext.
  ///
  /// In de, this message translates to:
  /// **'Anlass'**
  String get rtPretext;

  /// No description provided for @rtPretextParcel.
  ///
  /// In de, this message translates to:
  /// **'Paket'**
  String get rtPretextParcel;

  /// No description provided for @rtPretextPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort läuft ab'**
  String get rtPretextPassword;

  /// No description provided for @rtPretextInvoice.
  ///
  /// In de, this message translates to:
  /// **'Rechnung'**
  String get rtPretextInvoice;

  /// No description provided for @rtPretextBonus.
  ///
  /// In de, this message translates to:
  /// **'Bonus'**
  String get rtPretextBonus;

  /// No description provided for @rtUrgency.
  ///
  /// In de, this message translates to:
  /// **'Dringlichkeit'**
  String get rtUrgency;

  /// No description provided for @rtUrgencyNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get rtUrgencyNone;

  /// No description provided for @rtUrgencyToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get rtUrgencyToday;

  /// No description provided for @rtUrgencyHour.
  ///
  /// In de, this message translates to:
  /// **'1 Stunde'**
  String get rtUrgencyHour;

  /// No description provided for @rtPersonal.
  ///
  /// In de, this message translates to:
  /// **'Persönlich'**
  String get rtPersonal;

  /// No description provided for @rtPersonalNone.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get rtPersonalNone;

  /// No description provided for @rtPersonalName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get rtPersonalName;

  /// No description provided for @rtPersonalProject.
  ///
  /// In de, this message translates to:
  /// **'Name + Projekt'**
  String get rtPersonalProject;

  /// No description provided for @rtBait.
  ///
  /// In de, this message translates to:
  /// **'Köder'**
  String get rtBait;

  /// No description provided for @rtBaitLink.
  ///
  /// In de, this message translates to:
  /// **'Link'**
  String get rtBaitLink;

  /// No description provided for @rtBaitAttachment.
  ///
  /// In de, this message translates to:
  /// **'Anhang'**
  String get rtBaitAttachment;

  /// No description provided for @rtBaitQr.
  ///
  /// In de, this message translates to:
  /// **'QR-Code'**
  String get rtBaitQr;

  /// No description provided for @rtEthics.
  ///
  /// In de, this message translates to:
  /// **'Alles bleibt im Spiel: feste Bausteine, fiktive Firma und Domains, kein Export. Diese Übung zeigt, wie Angriffe funktionieren, damit du sie erkennst.'**
  String get rtEthics;

  /// No description provided for @rtLaunch.
  ///
  /// In de, this message translates to:
  /// **'An 100 Kollegen senden'**
  String get rtLaunch;

  /// No description provided for @rtRunning.
  ///
  /// In de, this message translates to:
  /// **'Die Kampagne läuft...'**
  String get rtRunning;

  /// No description provided for @rtDone.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis der Kampagne'**
  String get rtDone;

  /// No description provided for @rtClicked.
  ///
  /// In de, this message translates to:
  /// **'Geklickt'**
  String get rtClicked;

  /// No description provided for @rtReported.
  ///
  /// In de, this message translates to:
  /// **'Gemeldet'**
  String get rtReported;

  /// No description provided for @rtIgnored.
  ///
  /// In de, this message translates to:
  /// **'Ignoriert'**
  String get rtIgnored;

  /// No description provided for @rtVerdictHigh.
  ///
  /// In de, this message translates to:
  /// **'Erschreckend wirksam.'**
  String get rtVerdictHigh;

  /// No description provided for @rtVerdictMid.
  ///
  /// In de, this message translates to:
  /// **'Beachtlich: Das reicht für einen Einbruch.'**
  String get rtVerdictMid;

  /// No description provided for @rtVerdictLow.
  ///
  /// In de, this message translates to:
  /// **'Die meisten durchschauen das.'**
  String get rtVerdictLow;

  /// No description provided for @rtLesson.
  ///
  /// In de, this message translates to:
  /// **'Ein einziger Klick reicht Angreifern. Autorität, Zeitdruck und persönliche Details machen den Unterschied. Genau daran erkennst du Köder ab jetzt selbst. Und jede Meldung hilft: Die IT kann alle warnen, bevor der Nächste klickt.'**
  String get rtLesson;

  /// No description provided for @rtAgain.
  ///
  /// In de, this message translates to:
  /// **'Neue Kampagne'**
  String get rtAgain;

  /// No description provided for @checkIntro.
  ///
  /// In de, this message translates to:
  /// **'Füge den Text einer verdächtigen Nachricht ein oder lade einen Screenshot hoch.'**
  String get checkIntro;

  /// No description provided for @checkHint.
  ///
  /// In de, this message translates to:
  /// **'Text der Nachricht...'**
  String get checkHint;

  /// No description provided for @checkScreenshot.
  ///
  /// In de, this message translates to:
  /// **'Screenshot'**
  String get checkScreenshot;

  /// No description provided for @checkSample1.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Paket'**
  String get checkSample1;

  /// No description provided for @checkSample1Text.
  ///
  /// In de, this message translates to:
  /// **'Ihr Paket konnte nicht zugestellt werden. Zahlen Sie sofort 1,99 € Gebühr: paket-zustellung.xyz/x7'**
  String get checkSample1Text;

  /// No description provided for @checkSample2.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Neue Nummer'**
  String get checkSample2;

  /// No description provided for @checkSample2Text.
  ///
  /// In de, this message translates to:
  /// **'Hallo Mama, das ist meine neue Nummer. Kannst du mir schnell Geld überweisen? Sag es niemandem!'**
  String get checkSample2Text;

  /// No description provided for @checkButton.
  ///
  /// In de, this message translates to:
  /// **'Jetzt prüfen'**
  String get checkButton;

  /// No description provided for @checkDangerous.
  ///
  /// In de, this message translates to:
  /// **'Gefährlich'**
  String get checkDangerous;

  /// No description provided for @checkSuspicious.
  ///
  /// In de, this message translates to:
  /// **'Verdächtig'**
  String get checkSuspicious;

  /// No description provided for @checkUnclear.
  ///
  /// In de, this message translates to:
  /// **'Keine klaren Warnzeichen'**
  String get checkUnclear;

  /// No description provided for @checkRisk.
  ///
  /// In de, this message translates to:
  /// **'Risiko {score} von 100'**
  String checkRisk(Object score);

  /// No description provided for @checkSourceAi.
  ///
  /// In de, this message translates to:
  /// **'Analyse durch KI (Claude).'**
  String get checkSourceAi;

  /// No description provided for @checkSourceRules.
  ///
  /// In de, this message translates to:
  /// **'Analyse durch die lokale Regel-Prüfung, ohne KI.'**
  String get checkSourceRules;

  /// No description provided for @checkDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Eine Einschätzung, keine Garantie, und kein Ersatz für einen Virenscanner. Nachrichten werden nicht gespeichert. Entferne vor dem Hochladen persönliche Daten.'**
  String get checkDisclaimer;

  /// No description provided for @leagueTitle.
  ///
  /// In de, this message translates to:
  /// **'Liga'**
  String get leagueTitle;

  /// No description provided for @leagueTier.
  ///
  /// In de, this message translates to:
  /// **'{tier}-Liga'**
  String leagueTier(Object tier);

  /// No description provided for @leagueSub.
  ///
  /// In de, this message translates to:
  /// **'{xp} XP diese Woche. Die Top 7 steigen am Sonntag auf.'**
  String leagueSub(Object xp);

  /// No description provided for @tierBronze.
  ///
  /// In de, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In de, this message translates to:
  /// **'Silber'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In de, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierDiamond.
  ///
  /// In de, this message translates to:
  /// **'Diamant'**
  String get tierDiamond;

  /// No description provided for @boardWeek.
  ///
  /// In de, this message translates to:
  /// **'Woche'**
  String get boardWeek;

  /// No description provided for @boardGlobal.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get boardGlobal;

  /// No description provided for @boardCompany.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get boardCompany;

  /// No description provided for @boardEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch niemand hier. Sei die erste Person!'**
  String get boardEmpty;

  /// No description provided for @boardPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Ranglisten zeigen nur Spitznamen. In den Einstellungen kannst du dich ausblenden.'**
  String get boardPrivacy;

  /// No description provided for @statReporting.
  ///
  /// In de, this message translates to:
  /// **'Melderate'**
  String get statReporting;

  /// No description provided for @statAccuracy.
  ///
  /// In de, this message translates to:
  /// **'Trefferquote'**
  String get statAccuracy;

  /// No description provided for @statBestStreak.
  ///
  /// In de, this message translates to:
  /// **'Beste Serie'**
  String get statBestStreak;

  /// No description provided for @statReported.
  ///
  /// In de, this message translates to:
  /// **'Gemeldet'**
  String get statReported;

  /// No description provided for @statHacked.
  ///
  /// In de, this message translates to:
  /// **'Gehackt'**
  String get statHacked;

  /// No description provided for @statFalseAlarms.
  ///
  /// In de, this message translates to:
  /// **'Fehlalarme'**
  String get statFalseAlarms;

  /// No description provided for @badges.
  ///
  /// In de, this message translates to:
  /// **'Abzeichen'**
  String get badges;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @badgeFirstShift.
  ///
  /// In de, this message translates to:
  /// **'Erste Schicht'**
  String get badgeFirstShift;

  /// No description provided for @badgePerfectShift.
  ///
  /// In de, this message translates to:
  /// **'Perfekte Schicht'**
  String get badgePerfectShift;

  /// No description provided for @badgeFirstReport.
  ///
  /// In de, this message translates to:
  /// **'Erste Meldung'**
  String get badgeFirstReport;

  /// No description provided for @badgeReporter.
  ///
  /// In de, this message translates to:
  /// **'25 Meldungen'**
  String get badgeReporter;

  /// No description provided for @badgeCeo.
  ///
  /// In de, this message translates to:
  /// **'Chef-resistent'**
  String get badgeCeo;

  /// No description provided for @badgeMfa.
  ///
  /// In de, this message translates to:
  /// **'Eiserne Nerven'**
  String get badgeMfa;

  /// No description provided for @badgeMacro.
  ///
  /// In de, this message translates to:
  /// **'Makrojäger'**
  String get badgeMacro;

  /// No description provided for @badgeHomoglyph.
  ///
  /// In de, this message translates to:
  /// **'Adlerauge'**
  String get badgeHomoglyph;

  /// No description provided for @badgeQr.
  ///
  /// In de, this message translates to:
  /// **'QR-Skeptiker'**
  String get badgeQr;

  /// No description provided for @badgeFirstDuel.
  ///
  /// In de, this message translates to:
  /// **'Erstes Duell'**
  String get badgeFirstDuel;

  /// No description provided for @badgeDuelWinner.
  ///
  /// In de, this message translates to:
  /// **'Duellsieger'**
  String get badgeDuelWinner;

  /// No description provided for @badgeStreak3.
  ///
  /// In de, this message translates to:
  /// **'3 Tage Serie'**
  String get badgeStreak3;

  /// No description provided for @badgeStreak7.
  ///
  /// In de, this message translates to:
  /// **'7 Tage Serie'**
  String get badgeStreak7;

  /// No description provided for @badgeHardWay.
  ///
  /// In de, this message translates to:
  /// **'Daraus gelernt'**
  String get badgeHardWay;

  /// No description provided for @renameTitle.
  ///
  /// In de, this message translates to:
  /// **'Spitzname ändern'**
  String get renameTitle;

  /// No description provided for @settingLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingLanguage;

  /// No description provided for @settingSound.
  ///
  /// In de, this message translates to:
  /// **'Ton und Sprache'**
  String get settingSound;

  /// No description provided for @settingPublicBoard.
  ///
  /// In de, this message translates to:
  /// **'In öffentlichen Ranglisten zeigen'**
  String get settingPublicBoard;

  /// No description provided for @settingExport.
  ///
  /// In de, this message translates to:
  /// **'Meine Daten kopieren'**
  String get settingExport;

  /// No description provided for @settingExportSub.
  ///
  /// In de, this message translates to:
  /// **'Alles, was wir über dich speichern, als JSON (DSGVO)'**
  String get settingExportSub;

  /// No description provided for @settingExportDone.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten liegen in der Zwischenablage.'**
  String get settingExportDone;

  /// No description provided for @settingDelete.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen'**
  String get settingDelete;

  /// No description provided for @settingDeleteBody.
  ///
  /// In de, this message translates to:
  /// **'Dein Fortschritt und alle Daten werden endgültig gelöscht.'**
  String get settingDeleteBody;

  /// No description provided for @settingDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen'**
  String get settingDeleteConfirm;

  /// No description provided for @settingDemoReset.
  ///
  /// In de, this message translates to:
  /// **'Demo: Tag zurücksetzen'**
  String get settingDemoReset;

  /// No description provided for @settingDemoResetSub.
  ///
  /// In de, this message translates to:
  /// **'Heutige Schicht neu spielen, alle Wiederholungen fällig'**
  String get settingDemoResetSub;

  /// No description provided for @settingDemoResetDone.
  ///
  /// In de, this message translates to:
  /// **'Der Tag wurde zurückgesetzt.'**
  String get settingDemoResetDone;

  /// No description provided for @premiumTitle.
  ///
  /// In de, this message translates to:
  /// **'Tarife'**
  String get premiumTitle;

  /// No description provided for @premiumIntro.
  ///
  /// In de, this message translates to:
  /// **'Der Schutz vor Betrug bleibt kostenlos. Unternehmen finanzieren die soziale Seite mit.'**
  String get premiumIntro;

  /// No description provided for @premiumB2bTitle.
  ///
  /// In de, this message translates to:
  /// **'Für Unternehmen'**
  String get premiumB2bTitle;

  /// No description provided for @premiumNote.
  ///
  /// In de, this message translates to:
  /// **'Vorschau: In dieser Hackathon-Version ist noch keine Zahlung möglich. Preise sind Richtwerte.'**
  String get premiumNote;

  /// No description provided for @pricePremium.
  ///
  /// In de, this message translates to:
  /// **'3,99 € / Monat'**
  String get pricePremium;

  /// No description provided for @priceFamily.
  ///
  /// In de, this message translates to:
  /// **'5,99 € / Monat'**
  String get priceFamily;

  /// No description provided for @priceTeam.
  ///
  /// In de, this message translates to:
  /// **'2–3 € pro Person / Monat'**
  String get priceTeam;

  /// No description provided for @priceBusiness.
  ///
  /// In de, this message translates to:
  /// **'4–5 € pro Person / Monat'**
  String get priceBusiness;

  /// No description provided for @priceEnterprise.
  ///
  /// In de, this message translates to:
  /// **'Individuell'**
  String get priceEnterprise;

  /// No description provided for @planFree.
  ///
  /// In de, this message translates to:
  /// **'1 Schicht pro Tag, Grundlagen, Fehler wiederholen, 1 Duell pro Tag, einfacher Modus'**
  String get planFree;

  /// No description provided for @planPremium.
  ///
  /// In de, this message translates to:
  /// **'Ohne Limits, alle Module, Case Files, Red Team, Nachrichten-Check ohne Limit, Serien einfrieren'**
  String get planPremium;

  /// No description provided for @planFamily.
  ///
  /// In de, this message translates to:
  /// **'Bis zu 6 Personen: Schütze deine Eltern'**
  String get planFamily;

  /// No description provided for @planTeam.
  ///
  /// In de, this message translates to:
  /// **'Firmenliga, Admin-Panel, Berichte nach Abteilung, keine Limits'**
  String get planTeam;

  /// No description provided for @planBusiness.
  ///
  /// In de, this message translates to:
  /// **'Dazu eigene Szenarien, KI-Generator, SSO, Berichte für NIS2, ISO 27001 und TISAX'**
  String get planBusiness;

  /// No description provided for @planEnterprise.
  ///
  /// In de, this message translates to:
  /// **'Dazu Phishing-Übungen auf die echte Mail, Integrationen, SLA, EU-Hosting nach Wahl'**
  String get planEnterprise;

  /// No description provided for @adminTitle.
  ///
  /// In de, this message translates to:
  /// **'KÖDER für Unternehmen'**
  String get adminTitle;

  /// No description provided for @adminSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Human Risk Dashboard'**
  String get adminSubtitle;

  /// No description provided for @adminEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get adminEmail;

  /// No description provided for @adminPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get adminPassword;

  /// No description provided for @adminSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get adminSignIn;

  /// No description provided for @adminBadLogin.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Passwort stimmen nicht.'**
  String get adminBadLogin;

  /// No description provided for @adminLive.
  ///
  /// In de, this message translates to:
  /// **'Live'**
  String get adminLive;

  /// No description provided for @adminTabDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get adminTabDashboard;

  /// No description provided for @adminTabScenarios.
  ///
  /// In de, this message translates to:
  /// **'Szenarien'**
  String get adminTabScenarios;

  /// No description provided for @adminTabJury.
  ///
  /// In de, this message translates to:
  /// **'QR für alle'**
  String get adminTabJury;

  /// No description provided for @adminDemoData.
  ///
  /// In de, this message translates to:
  /// **'Demo-Unternehmen: Der Verlauf ist synthetisch. Antworten aus der App kommen live dazu.'**
  String get adminDemoData;

  /// No description provided for @adminReport.
  ///
  /// In de, this message translates to:
  /// **'Bericht für Audit (PDF)'**
  String get adminReport;

  /// No description provided for @adminRisk.
  ///
  /// In de, this message translates to:
  /// **'Human Risk Score'**
  String get adminRisk;

  /// No description provided for @riskLow.
  ///
  /// In de, this message translates to:
  /// **'Gering'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get riskHigh;

  /// No description provided for @adminReportingRate.
  ///
  /// In de, this message translates to:
  /// **'Melderate'**
  String get adminReportingRate;

  /// No description provided for @adminReportingHint.
  ///
  /// In de, this message translates to:
  /// **'Angriffe, die an die IT gingen'**
  String get adminReportingHint;

  /// No description provided for @adminClickRate.
  ///
  /// In de, this message translates to:
  /// **'Klickrate'**
  String get adminClickRate;

  /// No description provided for @adminClickHint.
  ///
  /// In de, this message translates to:
  /// **'Angriffe, die erfolgreich waren'**
  String get adminClickHint;

  /// No description provided for @adminDecisions.
  ///
  /// In de, this message translates to:
  /// **'Entscheidungen'**
  String get adminDecisions;

  /// No description provided for @adminDecisionsHint.
  ///
  /// In de, this message translates to:
  /// **'In den letzten 10 Wochen'**
  String get adminDecisionsHint;

  /// No description provided for @adminHeatmap.
  ///
  /// In de, this message translates to:
  /// **'Wo braucht es Training?'**
  String get adminHeatmap;

  /// No description provided for @adminHeatmapSub.
  ///
  /// In de, this message translates to:
  /// **'Risiko nach Abteilung und Angriffsart, 0 bis 100'**
  String get adminHeatmapSub;

  /// No description provided for @adminLegendLow.
  ///
  /// In de, this message translates to:
  /// **'geringes Risiko'**
  String get adminLegendLow;

  /// No description provided for @adminLegendHigh.
  ///
  /// In de, this message translates to:
  /// **'hohes Risiko'**
  String get adminLegendHigh;

  /// No description provided for @adminHidden.
  ///
  /// In de, this message translates to:
  /// **'Nicht ausgewiesen, weil zu klein: {names}'**
  String adminHidden(Object names);

  /// No description provided for @adminDepartments.
  ///
  /// In de, this message translates to:
  /// **'Abteilungen'**
  String get adminDepartments;

  /// No description provided for @adminColDepartment.
  ///
  /// In de, this message translates to:
  /// **'Abteilung'**
  String get adminColDepartment;

  /// No description provided for @adminColSize.
  ///
  /// In de, this message translates to:
  /// **'Größe'**
  String get adminColSize;

  /// No description provided for @adminColRisk.
  ///
  /// In de, this message translates to:
  /// **'Risiko'**
  String get adminColRisk;

  /// No description provided for @adminColReporting.
  ///
  /// In de, this message translates to:
  /// **'Melderate'**
  String get adminColReporting;

  /// No description provided for @adminTooSmall.
  ///
  /// In de, this message translates to:
  /// **'zu klein zum Anzeigen'**
  String get adminTooSmall;

  /// No description provided for @adminTrendRisk.
  ///
  /// In de, this message translates to:
  /// **'Risiko im Verlauf'**
  String get adminTrendRisk;

  /// No description provided for @adminTrendRiskSub.
  ///
  /// In de, this message translates to:
  /// **'Human Risk Score pro Woche'**
  String get adminTrendRiskSub;

  /// No description provided for @adminTrendReporting.
  ///
  /// In de, this message translates to:
  /// **'Melderate im Verlauf'**
  String get adminTrendReporting;

  /// No description provided for @adminTrendReportingSub.
  ///
  /// In de, this message translates to:
  /// **'Prozent der Angriffe pro Woche'**
  String get adminTrendReportingSub;

  /// No description provided for @adminFeed.
  ///
  /// In de, this message translates to:
  /// **'Gerade passiert'**
  String get adminFeed;

  /// No description provided for @adminFeedSub.
  ///
  /// In de, this message translates to:
  /// **'Nur Abteilungen, niemals Namen'**
  String get adminFeedSub;

  /// No description provided for @adminFeedEmpty.
  ///
  /// In de, this message translates to:
  /// **'Sobald jemand spielt, erscheint es hier.'**
  String get adminFeedEmpty;

  /// No description provided for @adminFeedLine.
  ///
  /// In de, this message translates to:
  /// **'{department}: {event} ({attack})'**
  String adminFeedLine(Object department, Object event, Object attack);

  /// No description provided for @feedReported.
  ///
  /// In de, this message translates to:
  /// **'Angriff gemeldet'**
  String get feedReported;

  /// No description provided for @feedHacked.
  ///
  /// In de, this message translates to:
  /// **'auf Angriff hereingefallen'**
  String get feedHacked;

  /// No description provided for @feedHandled.
  ///
  /// In de, this message translates to:
  /// **'richtig reagiert'**
  String get feedHandled;

  /// No description provided for @feedMissed.
  ///
  /// In de, this message translates to:
  /// **'nicht optimal reagiert'**
  String get feedMissed;

  /// No description provided for @adminPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz: Die Statistik wird ohne Personenbezug gespeichert. Abteilungen unter {min} Personen werden nicht ausgewiesen. So wird das Training zum Lernen und nicht zur Überwachung.'**
  String adminPrivacy(Object min);

  /// No description provided for @attackInvoice.
  ///
  /// In de, this message translates to:
  /// **'Rechnungs-betrug'**
  String get attackInvoice;

  /// No description provided for @attackCredentials.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Phishing'**
  String get attackCredentials;

  /// No description provided for @attackCeo.
  ///
  /// In de, this message translates to:
  /// **'CEO-Fraud'**
  String get attackCeo;

  /// No description provided for @attackAttachment.
  ///
  /// In de, this message translates to:
  /// **'Anhänge'**
  String get attackAttachment;

  /// No description provided for @attackSmishing.
  ///
  /// In de, this message translates to:
  /// **'SMS'**
  String get attackSmishing;

  /// No description provided for @attackVishing.
  ///
  /// In de, this message translates to:
  /// **'Anrufe'**
  String get attackVishing;

  /// No description provided for @attackQuishing.
  ///
  /// In de, this message translates to:
  /// **'QR-Codes'**
  String get attackQuishing;

  /// No description provided for @attackMfa.
  ///
  /// In de, this message translates to:
  /// **'MFA-Fatigue'**
  String get attackMfa;

  /// No description provided for @attackLegit.
  ///
  /// In de, this message translates to:
  /// **'echte Nachricht'**
  String get attackLegit;

  /// No description provided for @attackOther.
  ///
  /// In de, this message translates to:
  /// **'weitere Angriffe'**
  String get attackOther;

  /// No description provided for @genTitle.
  ///
  /// In de, this message translates to:
  /// **'Szenarien für Ihre Firma'**
  String get genTitle;

  /// No description provided for @genIntro.
  ///
  /// In de, this message translates to:
  /// **'Beschreiben Sie Ihr Unternehmen und erhalten Sie passende Übungen. Alles bleibt Entwurf, bis Sie es freigeben.'**
  String get genIntro;

  /// No description provided for @genCompany.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get genCompany;

  /// No description provided for @genIndustry.
  ///
  /// In de, this message translates to:
  /// **'Branche'**
  String get genIndustry;

  /// No description provided for @genTools.
  ///
  /// In de, this message translates to:
  /// **'Eingesetzte Systeme'**
  String get genTools;

  /// No description provided for @genPartners.
  ///
  /// In de, this message translates to:
  /// **'Lieferanten und Partner'**
  String get genPartners;

  /// No description provided for @genButton.
  ///
  /// In de, this message translates to:
  /// **'Szenarien erzeugen'**
  String get genButton;

  /// No description provided for @genSourceAi.
  ///
  /// In de, this message translates to:
  /// **'Erzeugt von KI (Claude). Bitte vor der Freigabe prüfen.'**
  String get genSourceAi;

  /// No description provided for @genSourceTemplate.
  ///
  /// In de, this message translates to:
  /// **'Aus Vorlagen erzeugt: Für KI-Texte muss ein API-Schlüssel gesetzt sein.'**
  String get genSourceTemplate;

  /// No description provided for @genAttack.
  ///
  /// In de, this message translates to:
  /// **'Angriff'**
  String get genAttack;

  /// No description provided for @genGenuine.
  ///
  /// In de, this message translates to:
  /// **'Echt'**
  String get genGenuine;

  /// No description provided for @genPublish.
  ///
  /// In de, this message translates to:
  /// **'Freigeben'**
  String get genPublish;

  /// No description provided for @genPublished.
  ///
  /// In de, this message translates to:
  /// **'Freigegeben'**
  String get genPublished;

  /// No description provided for @juryTitle.
  ///
  /// In de, this message translates to:
  /// **'Spielen Sie gegen uns!'**
  String get juryTitle;

  /// No description provided for @jurySub.
  ///
  /// In de, this message translates to:
  /// **'Scannen, und in Sekunden sind Sie im Duell. Ohne App und ohne Konto.'**
  String get jurySub;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
