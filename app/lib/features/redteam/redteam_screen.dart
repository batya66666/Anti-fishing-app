import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';

class _Block {
  const _Block(this.id, this.label, this.power, this.textDe, this.textEn);
  final String id;
  final String label;
  final double power;
  final String textDe;
  final String textEn;
}

/// "Become the hacker": build a phishing mail from fixed blocks and see how 100 simulated colleagues react.
/// Everything stays inside the game: fictional company, fixed text blocks, no free input, no export.
class RedTeamScreen extends StatefulWidget {
  const RedTeamScreen({super.key});

  @override
  State<RedTeamScreen> createState() => _RedTeamScreenState();
}

enum _Stage { build, running, done }

class _RedTeamScreenState extends State<RedTeamScreen> {
  String _sender = 'unknown';
  String _pretext = 'parcel';
  String _urgency = 'none';
  String _bait = 'link';
  String _personal = 'none';
  _Stage _stage = _Stage.build;
  final List<int> _npc = List.filled(100, 0); // 0 waiting, 1 ignored, 2 clicked, 3 reported
  Timer? _timer;
  int _clicked = 0;
  int _reported = 0;
  int _ignored = 0;

  List<_Block> _senders(AppLocalizations l) => [
        _Block('unknown', l.rtSenderUnknown, 0.02, 'info@gewinn-center.test', 'info@prize-center.test'),
        _Block('colleague', l.rtSenderColleague, 0.15, 'sabine.krueger@muster-autornotive.example', 'sabine.krueger@muster-autornotive.example'),
        _Block('it', l.rtSenderIt, 0.19, 'it-support@muster-automotive.test', 'it-support@muster-automotive.test'),
        _Block('boss', l.rtSenderBoss, 0.23, 'dr.mueller.gf@freemail.test', 'dr.mueller.gf@freemail.test'),
      ];

  List<_Block> _pretexts(AppLocalizations l) => [
        _Block('parcel', l.rtPretextParcel, 0.05, 'Ihr Paket wartet auf eine Bestätigung.', 'Your parcel is waiting for confirmation.'),
        _Block('password', l.rtPretextPassword, 0.13, 'Ihr Passwort läuft ab und muss erneuert werden.', 'Your password expires and must be renewed.'),
        _Block('invoice', l.rtPretextInvoice, 0.11, 'Anbei eine offene Rechnung, die noch zu prüfen ist.', 'Attached is an open invoice that still needs checking.'),
        _Block('bonus', l.rtPretextBonus, 0.17, 'Die Bonusliste für dieses Jahr ist jetzt verfügbar.', 'This year\'s bonus list is now available.'),
      ];

  List<_Block> _urgencies(AppLocalizations l) => [
        _Block('none', l.rtUrgencyNone, 0, '', ''),
        _Block('today', l.rtUrgencyToday, 0.07, 'Bitte noch heute erledigen.', 'Please deal with this today.'),
        _Block('hour', l.rtUrgencyHour, 0.12, 'Sie haben nur noch eine Stunde, sonst wird Ihr Konto gesperrt!', 'You only have one hour left, or your account will be locked!'),
      ];

  List<_Block> _baits(AppLocalizations l) => [
        _Block('link', l.rtBaitLink, 0.05, '[ Jetzt öffnen ]', '[ Open now ]'),
        _Block('attachment', l.rtBaitAttachment, 0.02, 'Anhang: Dokument.pdf.exe', 'Attachment: Document.pdf.exe'),
        _Block('qr', l.rtBaitQr, 0.07, 'Scannen Sie den QR-Code mit Ihrem Handy.', 'Scan the QR code with your phone.'),
      ];

  List<_Block> _personals(AppLocalizations l) => [
        _Block('none', l.rtPersonalNone, 0, 'Sehr geehrte Damen und Herren,', 'Dear Sir or Madam,'),
        _Block('name', l.rtPersonalName, 0.08, 'Guten Tag Frau Schneider,', 'Hello Ms Schneider,'),
        _Block('project', l.rtPersonalProject, 0.17, 'Guten Tag Frau Schneider, zu Ihrem Projekt "Mosel-Lieferkette":', 'Hello Ms Schneider, about your project "Mosel supply chain":'),
      ];

  double _power(AppLocalizations l) {
    double pick(List<_Block> list, String id) => list.firstWhere((b) => b.id == id).power;
    return pick(_senders(l), _sender) + pick(_pretexts(l), _pretext) + pick(_urgencies(l), _urgency) + pick(_baits(l), _bait) + pick(_personals(l), _personal);
  }

  void _launch(AppLocalizations l) {
    Sfx.play('alarm', volume: 0.3);
    final power = _power(l).clamp(0.02, 0.85);
    final r = Random();
    // Each colleague has their own attentiveness. Alert people report; distracted people click.
    final outcomes = List<int>.generate(100, (_) {
      final attention = r.nextDouble();
      final fall = power * (1.25 - attention);
      final roll = r.nextDouble();
      if (roll < fall) return 2;
      if (roll < fall + 0.1 + attention * 0.32 * (1 - power)) return 3;
      return 1;
    });
    final order = List<int>.generate(100, (i) => i)..shuffle(r);
    setState(() {
      _stage = _Stage.running;
      _npc.fillRange(0, 100, 0);
      _clicked = _reported = _ignored = 0;
    });
    var i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 42), (t) {
      if (i >= 100) {
        t.cancel();
        Sfx.success();
        setState(() => _stage = _Stage.done);
        return;
      }
      final index = order[i];
      final o = outcomes[index];
      setState(() {
        _npc[index] = o;
        if (o == 2) _clicked++;
        if (o == 3) _reported++;
        if (o == 1) _ignored++;
      });
      if (o == 2) Sfx.play('click', volume: 0.4);
      i++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _text(_Block b, bool de) => de ? b.textDe : b.textEn;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final de = Localizations.localeOf(context).languageCode != 'en';
    return Scaffold(
      appBar: AppBar(title: Text(l.modeRedTeam)),
      body: _stage == _Stage.build ? _builder(context, l, de) : _simulation(context, l),
    );
  }

  Widget _builder(BuildContext context, AppLocalizations l, bool de) {
    final sender = _senders(l).firstWhere((b) => b.id == _sender);
    final pretext = _pretexts(l).firstWhere((b) => b.id == _pretext);
    final urgency = _urgencies(l).firstWhere((b) => b.id == _urgency);
    final bait = _baits(l).firstWhere((b) => b.id == _bait);
    final personal = _personals(l).firstWhere((b) => b.id == _personal);
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
          Text(l.rtIntro, style: const TextStyle(color: K.muted, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: K.simBg, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_text(sender, de), style: const TextStyle(fontFamily: K.mono, fontSize: 12, color: K.simMuted)),
              const SizedBox(height: 8),
              Text(_text(personal, de), style: const TextStyle(color: K.simInk, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${_text(pretext, de)} ${_text(urgency, de)}'.trim(), style: const TextStyle(color: K.simInk, fontSize: 14, height: 1.35)),
              const SizedBox(height: 8),
              Text(_text(bait, de), style: const TextStyle(color: K.simLink, fontWeight: FontWeight.w600, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 14),
          _chooser(l.rtSender, _senders(l), _sender, (v) => setState(() => _sender = v)),
          _chooser(l.rtPretext, _pretexts(l), _pretext, (v) => setState(() => _pretext = v)),
          _chooser(l.rtUrgency, _urgencies(l), _urgency, (v) => setState(() => _urgency = v)),
          _chooser(l.rtPersonal, _personals(l), _personal, (v) => setState(() => _personal = v)),
          _chooser(l.rtBait, _baits(l), _bait, (v) => setState(() => _bait = v)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lock_outline, size: 15, color: K.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(l.rtEthics, style: Theme.of(context).textTheme.bodySmall)),
          ]),
        ]),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: K.danger, foregroundColor: Colors.white),
              onPressed: () => _launch(l),
              icon: const Icon(Icons.send),
              label: Text(l.rtLaunch),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _chooser(String title, List<_Block> blocks, String value, void Function(String) onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: K.muted)),
        const SizedBox(height: 6),
        Wrap(spacing: 7, runSpacing: 7, children: [
          for (final b in blocks)
            ChoiceChip(
              label: Text(b.label),
              selected: b.id == value,
              showCheckmark: false,
              selectedColor: K.tealDim,
              backgroundColor: K.surface,
              labelStyle: TextStyle(color: b.id == value ? K.teal : K.ink, fontWeight: FontWeight.w600),
              side: BorderSide(color: b.id == value ? K.teal : K.line),
              onSelected: (_) {
                Sfx.click();
                onPick(b.id);
              },
            ),
        ]),
      ]),
    );
  }

  Widget _simulation(BuildContext context, AppLocalizations l) {
    final done = _stage == _Stage.done;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
        Text(done ? l.rtDone : l.rtRunning, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          children: [
            for (final o in _npc)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: switch (o) {
                    2 => K.danger,
                    3 => K.teal,
                    1 => K.line,
                    _ => K.surface2,
                  },
                ),
                child: Icon(
                  switch (o) {
                    2 => Icons.close,
                    3 => Icons.flag,
                    _ => Icons.person,
                  },
                  size: 15,
                  color: o == 0 ? K.line : Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(children: [
          _count('$_clicked', l.rtClicked, K.danger),
          const SizedBox(width: 8),
          _count('$_reported', l.rtReported, K.teal),
          const SizedBox(width: 8),
          _count('$_ignored', l.rtIgnored, K.muted),
        ]),
        if (done) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: K.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_clicked >= 40 ? l.rtVerdictHigh : (_clicked >= 20 ? l.rtVerdictMid : l.rtVerdictLow), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text(l.rtLesson, style: const TextStyle(height: 1.45)),
            ]),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => setState(() => _stage = _Stage.build), icon: const Icon(Icons.refresh), label: Text(l.rtAgain)),
        ],
    ]);
  }

  Widget _count(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: K.line)),
        child: Column(children: [
          Text(value, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 26, color: color)),
          Text(label, style: const TextStyle(color: K.muted, fontSize: 12)),
        ]),
      ),
    );
  }
}
