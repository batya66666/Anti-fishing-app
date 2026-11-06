// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get backHome => 'Back to start';

  @override
  String get errorGeneric => 'That did not work. Please try again in a moment.';

  @override
  String get offlineBanner =>
      'Offline mode: you play locally, progress stays on this device.';

  @override
  String get hackedTitle => 'HACKED';

  @override
  String get hackedSubtitle => 'Your files have been encrypted.';

  @override
  String get hackedPay => 'Pay within 72 hours or all data will be deleted.';

  @override
  String get calmTitle => 'Don\'t worry: this was only training.';

  @override
  String get calmBody =>
      'In a real attack the whole company would now be affected. That is why we practise here, where it costs nothing. Let\'s see what could have warned you.';

  @override
  String get calmButton => 'Show me what I missed';

  @override
  String get simToMe => 'to me';

  @override
  String get actOk => 'All fine';

  @override
  String get actReply => 'Reply';

  @override
  String get actDelete => 'Delete';

  @override
  String get actReport => 'Report';

  @override
  String get actLeave => 'Leave';

  @override
  String get actOpen => 'Open';

  @override
  String get linkPeekTitle => 'This link really goes to:';

  @override
  String get openLink => 'Open anyway';

  @override
  String get simLoginTitle => 'Please sign in';

  @override
  String get simUser => 'Email or username';

  @override
  String get simPassword => 'Password';

  @override
  String get simSignIn => 'Sign in';

  @override
  String get callIncoming => 'Incoming call';

  @override
  String get callDecline => 'Decline';

  @override
  String get callAccept => 'Accept';

  @override
  String get callYourAnswer => 'Your answer:';

  @override
  String get qrLeadsTo => 'The code leads to:';

  @override
  String get qrScan => 'Scan code';

  @override
  String get qrOpen => 'Open';

  @override
  String get qrIgnore => 'Don\'t open';

  @override
  String get pushApprove => 'Approve';

  @override
  String get pushDeny => 'Deny';

  @override
  String get fileDownloads => 'Downloads';

  @override
  String get fileDetails => 'Show details';

  @override
  String get fileRealName => 'Real file name';

  @override
  String get fileType => 'Type';

  @override
  String get resultReported => 'Reported! Attack stopped.';

  @override
  String get resultWellDone => 'Well spotted!';

  @override
  String get resultGenuine => 'Right: this one was genuine.';

  @override
  String get resultSafe => 'Not fooled, but...';

  @override
  String get resultHacked => 'You fell for it.';

  @override
  String get resultFalseAlarm => 'False alarm: this one was genuine.';

  @override
  String get resultMissed => 'That was not the best reaction.';

  @override
  String redFlagsTitle(Object count) {
    return '$count red flags';
  }

  @override
  String get lessonStart => 'Let\'s go';

  @override
  String get reviewEmpty => 'Nothing to review right now. Nice!';

  @override
  String runDone(Object correct, Object total) {
    return '$correct of $total correct';
  }

  @override
  String get onbTitle1 => 'Five minutes a day';

  @override
  String get onbBody1 =>
      'You work in an office and your inbox keeps filling up. Which message is real, which is an attack?';

  @override
  String get onbTitle2 => 'Mistakes are welcome';

  @override
  String get onbBody2 =>
      'If you take the bait, you get \"hacked\" here. That sticks in your memory but costs nothing. Real life would be different.';

  @override
  String get onbTitle3 => 'Reporting wins';

  @override
  String get onbBody3 =>
      'Not clicking is good. Reporting is better. Duel with others and work your way from intern to CISO.';

  @override
  String get onbStart => 'Start working';

  @override
  String get onbLanguage => 'Language';

  @override
  String get onbMode => 'How would you like to practise?';

  @override
  String get modeOffice => 'Office';

  @override
  String get modeOfficeBody => 'Full shifts, duels, leagues and badges';

  @override
  String get modeSimple => 'Simple mode';

  @override
  String get modeSimpleBody =>
      'Large text, no time pressure, no rankings: spotting everyday scams';

  @override
  String get onbPrivacy =>
      'An account is optional. As a guest you play anonymously, and only you see your mistakes.';

  @override
  String get tabWork => 'Work';

  @override
  String get tabDuel => 'Duel';

  @override
  String get tabLeague => 'League';

  @override
  String get tabProfile => 'Profile';

  @override
  String levelLine(Object level, Object title) {
    return 'Level $level · $title';
  }

  @override
  String xpLine(Object xp, Object ceil) {
    return '$xp / $ceil XP';
  }

  @override
  String get shiftCardTitle => 'Your shift is starting';

  @override
  String get shiftCardBody =>
      'New messages are waiting in your inbox. Protect the company.';

  @override
  String get shiftStart => 'Start shift';

  @override
  String reviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mistakes are waiting to be reviewed',
      one: '1 mistake is waiting to be reviewed',
    );
    return '$_temp0';
  }

  @override
  String get modeSwipe => 'Swipe';

  @override
  String get modeFlags => 'Spot the flags';

  @override
  String get modeFlagsSub => 'Tap everything suspicious';

  @override
  String get modeCases => 'Case Files';

  @override
  String get modeCasesSub => 'Replay real attacks';

  @override
  String get checkTitle => 'Check a message';

  @override
  String get checkTileSub => 'Got something suspicious? Check it here.';

  @override
  String get skillTree => 'Your learning path';

  @override
  String get skillTreeSub =>
      'All 13 topics are open: the basics are always free.';

  @override
  String get module1 => 'Basics';

  @override
  String get module2 => 'Senders';

  @override
  String get module3 => 'Links & URLs';

  @override
  String get module4 => 'Attachments';

  @override
  String get module5 => 'Invoices & CEO fraud';

  @override
  String get module6 => 'SMS & messengers';

  @override
  String get module7 => 'Calls & deepfakes';

  @override
  String get module8 => 'QR codes';

  @override
  String get module9 => 'Accounts & passwords';

  @override
  String get module10 => 'Work laptop';

  @override
  String get module11 => 'Social networks';

  @override
  String get module12 => 'On site';

  @override
  String get module13 => 'What if you clicked?';

  @override
  String get tip1 =>
      'Fraudsters target your feelings: urgency, fear, authority, curiosity and greed. If you suddenly feel pressure, that is exactly the moment to pause.';

  @override
  String get tip2 =>
      'The display name proves nothing. Tap the sender and read the real address. Look for swapped letters and foreign domains.';

  @override
  String get tip3 =>
      'Read an address from right to left: the part right before the first slash decides who owns the site. The padlock only means \"encrypted\", not \"safe\". Long-press links to see where they go.';

  @override
  String get tip4 =>
      'Invoices are not programs. Beware of .exe, .lnk, .iso and macro files such as .xlsm, as well as double extensions and password-protected archives.';

  @override
  String get tip5 =>
      'Bank details rarely change by email. Verify every change by phone on the known number. Even the boss has to follow the four-eyes principle.';

  @override
  String get tip6 =>
      'Parcel, bank, \"Hi Mum\": these messages want you to click or pay. Open the app yourself or call the known number.';

  @override
  String get tip7 =>
      'Voices can be cloned from a few seconds of audio and displayed numbers can be faked. Hang up and call back yourself on the known number.';

  @override
  String get tip8 =>
      'You cannot see where a QR code leads. Check the address after scanning and look out for stickers over the original.';

  @override
  String get tip9 =>
      'A separate password for every service, ideally from a password manager. Never approve a sign-in you did not start yourself.';

  @override
  String get tip10 =>
      'The work laptop is for work only: no games, no mods, no private downloads. Public Wi-Fi only with VPN. Always lock it when you walk away.';

  @override
  String get tip11 =>
      'Attackers read along: name, department and systems are enough for the perfect email. Share your successes, but no details about internal processes.';

  @override
  String get tip12 =>
      'A hi-vis vest and full hands open many doors. Take strangers to reception in a friendly way. Found items like USB sticks go to IT, not into a computer.';

  @override
  String get tip13 =>
      'It can happen to anyone. Disconnect the network and call IT at once. Every minute counts and nobody will judge you for it.';

  @override
  String get simpleWelcome => 'Glad you are here';

  @override
  String get simplePractice => 'Practise today';

  @override
  String get simplePracticeBody => 'Look at a few messages in peace';

  @override
  String get simplePracticeDone => 'Done. Another round?';

  @override
  String get simpleReview => 'Review';

  @override
  String get simpleLearn => 'Scams by text and call';

  @override
  String get simpleLearnBody => 'Learn the most common tricks';

  @override
  String get simpleLeave => 'Switch to office mode';

  @override
  String get shiftTitle => 'Today\'s shift';

  @override
  String get shiftHint =>
      'Deal with everything that comes in. Tip: tap the sender, long-press links.';

  @override
  String get backToInbox => 'Back to inbox';

  @override
  String get shiftFinish => 'Finish shift';

  @override
  String get inboxCall => 'Incoming call';

  @override
  String get reportTitle => 'Shift complete';

  @override
  String reportProtected(Object good, Object total) {
    return 'You protected the company correctly $good of $total times.';
  }

  @override
  String promotion(Object title) {
    return 'Promotion! You are now: $title';
  }

  @override
  String get streak => 'Streak';

  @override
  String get reportedShort => 'Reported';

  @override
  String get reportMissed => 'What to take away';

  @override
  String get reportWillReturn =>
      'These cases return in 1, 3 and 7 days until they stick.';

  @override
  String get reportRest =>
      'Good shift! Your brain needs a rest now and tomorrow brings a new case.';

  @override
  String get swipePhishing => 'Phishing';

  @override
  String get swipeGenuine => 'Genuine';

  @override
  String swipeResult(Object correct, Object total) {
    return '$correct of $total correct';
  }

  @override
  String get flagsDone => 'points for your keen eye';

  @override
  String get flagsHint => 'Tap everything that looks suspicious, then check.';

  @override
  String flagsSubmit(Object count) {
    return 'Check ($count marked)';
  }

  @override
  String flagsResult(Object found, Object total, Object wrong) {
    return '$found of $total found, $wrong marked wrongly';
  }

  @override
  String get reviewTitle => 'Review mistakes';

  @override
  String get duelTitle => 'PvP duel';

  @override
  String get duelSub => 'Same tasks, same time: who spots more?';

  @override
  String duelRecord(Object wins, Object losses) {
    return '$wins wins · $losses losses';
  }

  @override
  String get duelFind => 'Find an opponent';

  @override
  String get duelSearching => 'Looking for an opponent...';

  @override
  String get duelFriendly => 'Play with friends';

  @override
  String get duelCreateCode => 'Create code and QR';

  @override
  String get duelCodeHint => 'Code';

  @override
  String get duelJoin => 'Join';

  @override
  String get duelVsBot => 'Practise against the bot';

  @override
  String get duelBotShort => 'Play bot';

  @override
  String get duelScanMe => 'Scan to play';

  @override
  String get duelWaiting => 'Waiting for an opponent...';

  @override
  String get duelNeedsServer =>
      'Duels by code need a connection to the server. The bot is available offline.';

  @override
  String get duelBadCode =>
      'This code does not exist or the duel has already started.';

  @override
  String get duelConnecting => 'Connecting...';

  @override
  String get duelWaitingOpponent => 'Waiting for your opponent...';

  @override
  String duelRound(Object round, Object total) {
    return 'Round $round/$total';
  }

  @override
  String get duelBothDone => 'Both have answered';

  @override
  String get duelWaitOther => 'Waiting for your opponent';

  @override
  String get duelWrong => 'Missed!';

  @override
  String get duelWasAttack => 'That was an attack.';

  @override
  String get duelWasGenuine => 'That was genuine.';

  @override
  String get duelWon => 'You won!';

  @override
  String get duelLost => 'So close';

  @override
  String get duelDraw => 'A draw';

  @override
  String get duelReview => 'What to take away';

  @override
  String get casesIntro =>
      'Real incidents to replay. You can stop the attack at every step. Can you do what nobody managed back then?';

  @override
  String get caseStopped => 'Attack stopped!';

  @override
  String get caseContinues => 'The attack continues...';

  @override
  String get caseWinTitle => 'You would have prevented it.';

  @override
  String get caseLoseTitle => 'This is how it really happened.';

  @override
  String get caseReality => 'What really happened';

  @override
  String get caseSources => 'Sources';

  @override
  String get checkIntro =>
      'Paste the text of a suspicious message or upload a screenshot.';

  @override
  String get checkHint => 'Text of the message...';

  @override
  String get checkScreenshot => 'Screenshot';

  @override
  String get checkSample1 => 'Example: parcel';

  @override
  String get checkSample1Text =>
      'Your parcel could not be delivered. Pay a €1.99 fee immediately: parcel-delivery.xyz/x7';

  @override
  String get checkSample2 => 'Example: new number';

  @override
  String get checkSample2Text =>
      'Hi Mum, this is my new number. Can you quickly wire me some money? Do not tell anyone!';

  @override
  String get checkButton => 'Check now';

  @override
  String get checkDangerous => 'Dangerous';

  @override
  String get checkSuspicious => 'Suspicious';

  @override
  String get checkUnclear => 'No clear warning signs';

  @override
  String checkRisk(Object score) {
    return 'Risk $score of 100';
  }

  @override
  String get checkSourceAi => 'Analysis by AI (Claude).';

  @override
  String get checkSourceRules =>
      'Analysis by the local rule check, without AI.';

  @override
  String get checkDisclaimer =>
      'An assessment, no guarantee, and no substitute for a virus scanner. Messages are not stored. Remove personal data before uploading.';

  @override
  String get leagueTitle => 'League';

  @override
  String leagueTier(Object tier) {
    return '$tier league';
  }

  @override
  String leagueSub(Object xp) {
    return '$xp XP this week. The top 7 move up on Sunday.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get boardWeek => 'Week';

  @override
  String get boardGlobal => 'All-time';

  @override
  String get boardCompany => 'Company';

  @override
  String get boardEmpty => 'Nobody here yet. Be the first!';

  @override
  String get boardPrivacy =>
      'Leaderboards show nicknames only. You can hide yourself in the settings.';

  @override
  String get statReporting => 'Reporting rate';

  @override
  String get statAccuracy => 'Accuracy';

  @override
  String get statBestStreak => 'Best streak';

  @override
  String get statReported => 'Reported';

  @override
  String get statHacked => 'Hacked';

  @override
  String get statFalseAlarms => 'False alarms';

  @override
  String get badges => 'Badges';

  @override
  String get settings => 'Settings';

  @override
  String get badgeFirstShift => 'First shift';

  @override
  String get badgePerfectShift => 'Perfect shift';

  @override
  String get badgeFirstReport => 'First report';

  @override
  String get badgeReporter => '25 reports';

  @override
  String get badgeCeo => 'Boss-proof';

  @override
  String get badgeMfa => 'Iron nerves';

  @override
  String get badgeMacro => 'Macro hunter';

  @override
  String get badgeHomoglyph => 'Eagle eye';

  @override
  String get badgeQr => 'QR sceptic';

  @override
  String get badgeFirstDuel => 'First duel';

  @override
  String get badgeDuelWinner => 'Duel winner';

  @override
  String get badgeStreak3 => '3-day streak';

  @override
  String get badgeStreak7 => '7-day streak';

  @override
  String get badgeHardWay => 'Learned from it';

  @override
  String get renameTitle => 'Change nickname';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingSound => 'Sound';

  @override
  String get settingPublicBoard => 'Show on public leaderboards';

  @override
  String get settingExport => 'Copy my data';

  @override
  String get settingExportSub =>
      'Everything we store about you, as JSON (GDPR)';

  @override
  String get settingExportDone => 'Your data is on the clipboard.';

  @override
  String get settingDelete => 'Delete account';

  @override
  String get settingDeleteBody =>
      'Your progress and all data will be permanently deleted.';

  @override
  String get settingDeleteConfirm => 'Delete for good';

  @override
  String get settingDemoReset => 'Demo: reset the day';

  @override
  String get settingDemoResetSub => 'Replay today\'s shift, all reviews due';

  @override
  String get settingDemoResetDone => 'The day has been reset.';

  @override
  String get premiumTitle => 'Plans';

  @override
  String get premiumIntro =>
      'Protection from scams stays free. Companies help fund the social side.';

  @override
  String get premiumB2bTitle => 'For companies';

  @override
  String get premiumNote =>
      'Preview: no payment is possible in this hackathon version. Prices are indicative.';

  @override
  String get pricePremium => '€3.99 / month';

  @override
  String get priceFamily => '€5.99 / month';

  @override
  String get priceTeam => '€2–3 per person / month';

  @override
  String get priceBusiness => '€4–5 per person / month';

  @override
  String get priceEnterprise => 'Custom';

  @override
  String get planFree =>
      'Unlimited play: shifts, endless mode, duels, learning path, simple mode';

  @override
  String get planPremium =>
      'Case files, unlimited message checks, streak freezes';

  @override
  String get planFamily => 'Up to 6 people: protect your parents';

  @override
  String get planTeam => 'Company league, admin panel, reports by department';

  @override
  String get planBusiness =>
      'Plus custom scenarios, AI generator, SSO, reports for NIS2, ISO 27001 and TISAX';

  @override
  String get planEnterprise =>
      'Plus phishing exercises on real mail, integrations, SLA, EU hosting of your choice';

  @override
  String get adminTitle => 'KÖDER for companies';

  @override
  String get adminSubtitle => 'Human Risk Dashboard';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminSignIn => 'Sign in';

  @override
  String get adminBadLogin => 'Email or password is incorrect.';

  @override
  String get adminLive => 'Live';

  @override
  String get adminTabDashboard => 'Dashboard';

  @override
  String get adminTabScenarios => 'Scenarios';

  @override
  String get adminTabJury => 'QR for all';

  @override
  String get adminDemoData =>
      'Demo company: the history is synthetic. Answers from the app are added live.';

  @override
  String get adminReport => 'Audit report (PDF)';

  @override
  String get adminRisk => 'Human Risk Score';

  @override
  String get riskLow => 'Low';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskHigh => 'High';

  @override
  String get adminReportingRate => 'Reporting rate';

  @override
  String get adminReportingHint => 'Attacks passed on to IT';

  @override
  String get adminClickRate => 'Click rate';

  @override
  String get adminClickHint => 'Attacks that succeeded';

  @override
  String get adminDecisions => 'Decisions';

  @override
  String get adminDecisionsHint => 'In the last 10 weeks';

  @override
  String get adminHeatmap => 'Where is training needed?';

  @override
  String get adminHeatmapSub =>
      'Risk by department and type of attack, 0 to 100';

  @override
  String get adminLegendLow => 'low risk';

  @override
  String get adminLegendHigh => 'high risk';

  @override
  String adminHidden(Object names) {
    return 'Not shown because too small: $names';
  }

  @override
  String get adminDepartments => 'Departments';

  @override
  String get adminColDepartment => 'Department';

  @override
  String get adminColSize => 'Size';

  @override
  String get adminColRisk => 'Risk';

  @override
  String get adminColReporting => 'Reporting';

  @override
  String get adminTooSmall => 'too small to show';

  @override
  String get adminTrendRisk => 'Risk over time';

  @override
  String get adminTrendRiskSub => 'Human Risk Score per week';

  @override
  String get adminTrendReporting => 'Reporting rate over time';

  @override
  String get adminTrendReportingSub => 'Percent of attacks per week';

  @override
  String get adminFeed => 'Just now';

  @override
  String get adminFeedSub => 'Departments only, never names';

  @override
  String get adminFeedEmpty => 'It appears here as soon as someone plays.';

  @override
  String adminFeedLine(Object department, Object event, Object attack) {
    return '$department: $event ($attack)';
  }

  @override
  String get feedReported => 'attack reported';

  @override
  String get feedHacked => 'fell for an attack';

  @override
  String get feedHandled => 'handled correctly';

  @override
  String get feedMissed => 'reaction not ideal';

  @override
  String adminPrivacy(Object min) {
    return 'Privacy: statistics are stored without reference to a person. Departments below $min people are not shown. That keeps the training about learning, not surveillance.';
  }

  @override
  String get attackInvoice => 'Invoice fraud';

  @override
  String get attackCredentials => 'Password phishing';

  @override
  String get attackCeo => 'CEO fraud';

  @override
  String get attackAttachment => 'Attachments';

  @override
  String get attackSmishing => 'Smishing';

  @override
  String get attackVishing => 'Vishing';

  @override
  String get attackQuishing => 'Quishing';

  @override
  String get attackMfa => 'MFA fatigue';

  @override
  String get attackLegit => 'genuine message';

  @override
  String get attackOther => 'other attacks';

  @override
  String get genTitle => 'Scenarios for your company';

  @override
  String get genIntro =>
      'Describe your company and receive matching exercises. Everything stays a draft until you approve it.';

  @override
  String get genCompany => 'Company';

  @override
  String get genIndustry => 'Industry';

  @override
  String get genTools => 'Systems in use';

  @override
  String get genPartners => 'Suppliers and partners';

  @override
  String get genButton => 'Generate scenarios';

  @override
  String get genSourceAi =>
      'Generated by AI (Claude). Please review before approving.';

  @override
  String get genSourceTemplate =>
      'Generated from templates: AI text requires an API key to be set.';

  @override
  String get genAttack => 'Attack';

  @override
  String get genGenuine => 'Genuine';

  @override
  String get genPublish => 'Approve';

  @override
  String get genPublished => 'Approved';

  @override
  String get juryTitle => 'Play against us!';

  @override
  String get jurySub =>
      'Scan, and you are in a duel within seconds. No app, no account.';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourDone => 'Let\'s go!';

  @override
  String get tourAgain => 'Repeat the tour';

  @override
  String get tourWelcomeTitle => 'Hi, I\'m Baity!';

  @override
  String get tourWelcomeBody =>
      'Let me quickly show you where everything is. Don\'t worry, it only takes a minute.';

  @override
  String get tourLevelTitle => 'Your rank';

  @override
  String get tourLevelBody =>
      'This is where you climb from intern to CISO. Every right decision earns XP.';

  @override
  String get tourShiftTitle => 'Your shift';

  @override
  String get tourShiftBody =>
      'The heart of the game: your inbox fills up and you decide what is real. Half of the messages are harmless.';

  @override
  String get tourEndlessTitle => 'Play endlessly';

  @override
  String get tourEndlessBody =>
      'Question after question, no limit, at the difficulty you choose.';

  @override
  String get tourModesTitle => 'More training';

  @override
  String get tourModesBody =>
      'Swipe against the clock, hunt for red flags, replay real cases, or check a message of your own.';

  @override
  String get tourCheckTitle => 'Check a real message';

  @override
  String get tourCheckBody =>
      'Got something suspicious? Paste it here and I will take a look.';

  @override
  String get tourPathTitle => 'Your learning path';

  @override
  String get tourPathBody =>
      '13 topics. Your progress is saved: you always continue exactly where you stopped.';

  @override
  String get tourDuelTitle => 'Duels';

  @override
  String get tourDuelBody =>
      'Play live against others or challenge a bot, from intern to CISO.';

  @override
  String get tourLeagueTitle => 'League';

  @override
  String get tourLeagueBody => 'Collect XP during the week and move up.';

  @override
  String get tourProfileTitle => 'Profile';

  @override
  String get tourProfileBody =>
      'Your stats and badges, plus account, language and this tour.';

  @override
  String get tourInboxTitle => 'Your inbox';

  @override
  String get tourInboxBody =>
      'Messages keep arriving on their own. Tap one. Careful: calls can interrupt you at any time.';

  @override
  String get tourProgressTitle => 'Attacks fended off';

  @override
  String get tourProgressBody =>
      'This shows how many messages you handled correctly.';

  @override
  String get tourSenderTitle => 'Who is really writing?';

  @override
  String get tourSenderBody =>
      'The name can claim anything. Tap the sender to see the real address.';

  @override
  String get tourContentTitle => 'Links and attachments';

  @override
  String get tourContentBody =>
      'Hold your finger on a link to see where it goes. A PDF opens in a preview, but PDFs can hold phishing too.';

  @override
  String get tourActionsTitle => 'Your decision';

  @override
  String get tourActionsBody =>
      'Genuine? Tap \"All fine\". An attack? Reporting is the best thing you can do. Fall for it and you get hacked. Report something genuine and you are paranoid.';

  @override
  String get onbWelcomeLanguage => 'Willkommen! Welcome!';

  @override
  String get onbChooseLanguage => 'Choose your language';

  @override
  String get authRegisterTitle => 'Create an account';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authWhy =>
      'With an account your progress stays with you, even on another device.';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authLogin => 'Sign in';

  @override
  String get authLogout => 'Sign out';

  @override
  String get authGuest => 'Continue as a guest';

  @override
  String get authName => 'Your name in the game (optional)';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String authPasswordHint(int count) {
    return 'At least $count characters';
  }

  @override
  String authShortPassword(int count) {
    return 'The password needs at least $count characters.';
  }

  @override
  String get authBadEmail => 'Please enter a valid email address.';

  @override
  String get authBadLogin => 'Wrong email or password.';

  @override
  String get authTaken =>
      'There already is an account for this email. Please sign in.';

  @override
  String get authNeedsServer =>
      'Accounts need a connection to the server. You can keep playing offline as a guest.';

  @override
  String get authInsecure =>
      'This demo network runs without HTTPS. Do not use a password here that you use anywhere else.';

  @override
  String get authAccountGuest => 'You are playing as a guest';

  @override
  String get authAccountGuestSub => 'Create an account to keep your progress';

  @override
  String get authAccountHave => 'I already have an account';

  @override
  String get endlessTitle => 'Endless mode';

  @override
  String get endlessSub => 'No limit';

  @override
  String get endlessIntro =>
      'Question after question, as long as you like. New ones first, then what you have not seen for the longest time.';

  @override
  String get endlessStart => 'Start';

  @override
  String get endlessNext => 'Next question';

  @override
  String get retry => 'Try again';

  @override
  String get difficultyTitle => 'Difficulty';

  @override
  String get difficultyMix => 'Mixed';

  @override
  String get difficultyMixBody => 'All levels, half of them hard';

  @override
  String get difficultyBronze => 'Bronze';

  @override
  String get difficultySilver => 'Silver';

  @override
  String get difficultyGold => 'Gold';

  @override
  String get difficultyDiamond => 'Diamond';

  @override
  String get difficultyBronzeBody => 'Classics you need to know';

  @override
  String get difficultySilverBody => 'The usual tricks, well made';

  @override
  String get difficultyGoldBody => 'Plausible and flawless, often with a PDF';

  @override
  String get difficultyDiamondBody =>
      'Real accounts, cloned voices: almost impossible to spot';

  @override
  String difficultyForced(String level) {
    return 'The admin has set \"$level\" for everyone.';
  }

  @override
  String get pdfScan => 'Scan the code with my phone';

  @override
  String get pdfHoldHint =>
      'Hold your finger or right-click to see the destination.';

  @override
  String get pdfBack => 'Back to the message';

  @override
  String get simReplyTo => 'Reply to';

  @override
  String get shiftAgainTitle => 'Shift done!';

  @override
  String get shiftAgainBody => 'Good work. Want more? There is no daily limit.';

  @override
  String get shiftAgain => 'Another shift';

  @override
  String get swipeSub => '60 seconds against the clock';

  @override
  String get swipeAgain => 'Another round';

  @override
  String get flagsAgain => 'Another round';

  @override
  String get moduleContinue => 'Continue learning';

  @override
  String moduleProgress(int done, int total) {
    return '$done of $total solved';
  }

  @override
  String get moduleDone => 'Done';

  @override
  String get moduleRetry => 'Repeat my mistakes';

  @override
  String get pathDone => 'Learning path complete!';

  @override
  String get hackedFalseAlarmBody =>
      'But your alarm held up real work. Whoever reports everything soon stops being taken seriously, also at the next real attack.';

  @override
  String get hackedMissedBody =>
      'That was not the safe choice. In real life, exactly this could have hit you. See what could have warned you.';

  @override
  String get botPickTitle => 'Who do you want to play?';

  @override
  String get botAuto => 'Matched to me';

  @override
  String get botAutoBody => 'Adapts to your strength and stays exciting';

  @override
  String get botRookie => 'Otto the intern';

  @override
  String get botRookieBody => 'Reads slowly, falls for a lot';

  @override
  String get botAnalyst => 'Grete the analyst';

  @override
  String get botAnalystBody => 'Solid, but unsure on hard cases';

  @override
  String get botVeteran => 'Kalle the veteran';

  @override
  String get botVeteranBody => 'Fast, makes hardly any mistakes';

  @override
  String get botCiso => 'Frieda the CISO';

  @override
  String get botCisoBody =>
      'The final boss. Lightning fast and almost flawless';

  @override
  String get adminTabDifficulty => 'Difficulty';

  @override
  String get adminDifficultyTitle => 'Set the difficulty';

  @override
  String get adminDifficultyIntro =>
      'To demonstrate and to check: the chosen level applies at once to all players of the company, in shifts, the endless mode, swiping and duels.';

  @override
  String get adminDifficultyOff => 'Normal';

  @override
  String get adminDifficultyOffBody =>
      'Normal play: the difficulty follows the player.';

  @override
  String get adminDifficultySaved => 'Saved. Applies from the next question.';

  @override
  String get adminCatalogTitle => 'Review all scenarios';

  @override
  String adminCatalogSub(int count) {
    return '$count scenarios with solutions. Tap one to see it as it appears in the game.';
  }

  @override
  String get adminCatalogAll => 'All';

  @override
  String get adminCatalogPdfOnly => 'PDF only';

  @override
  String get adminWifiTitle => 'Join on the Wi-Fi';

  @override
  String get adminWifiSub =>
      'Everyone on the same Wi-Fi just opens this address:';

  @override
  String get paranoidTitle => 'PARANOID!';

  @override
  String get paranoidSub =>
      'That was genuine. Your alarm went off over a harmless message.';

  @override
  String get paranoidCalmTitle => 'Nobody got hacked.';

  @override
  String get paranoidButton => 'Show me how I could have told';

  @override
  String get theoryTitle => 'Theory';

  @override
  String get theoryRead => 'Read the theory (optional)';

  @override
  String get theoryOptional => 'Read the theory first (optional)';

  @override
  String get theoryIntro =>
      'Entirely optional: you can also start right away and learn as you go.';

  @override
  String get botNoElo => 'Games against bots do not change your ELO.';
}
