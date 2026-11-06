import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/duel_client.dart';
import '../../data/models.dart';
import '../../effects/confetti.dart';
import '../../effects/mascot.dart';
import '../../simulators/common.dart';
import '../../simulators/mail_sim.dart';
import '../../simulators/scenario_view.dart';

enum _Phase { connecting, versus, countdown, round, result, finished }

const _reactions = {
  'fire': (Icons.local_fire_department, K.warn),
  'bolt': (Icons.bolt, Color(0xFFFFD166)),
  'fish': (Icons.phishing, K.teal),
  'shock': (Icons.sentiment_very_dissatisfied, K.violet),
  'laugh': (Icons.sentiment_very_satisfied, Color(0xFF7BE36A)),
  'shield': (Icons.shield, K.blue),
};

class _FloatingReaction {
  _FloatingReaction(this.key, this.emoji, this.mine, this.dx);
  final int key;
  final String emoji;
  final bool mine;
  final double dx;
}

/// A live duel: same rounds for both players, the server keeps time and score.
class DuelMatchScreen extends ConsumerStatefulWidget {
  const DuelMatchScreen({super.key, required this.duelId});
  final String duelId;

  @override
  ConsumerState<DuelMatchScreen> createState() => _DuelMatchScreenState();
}

class _DuelMatchScreenState extends ConsumerState<DuelMatchScreen> {
  late final DuelClient _client;
  StreamSubscription<Map<String, dynamic>>? _sub;
  _Phase _phase = _Phase.connecting;
  String? _myKey;
  Map<String, dynamic> _a = {};
  Map<String, dynamic> _b = {};
  int _scoreA = 0;
  int _scoreB = 0;
  int _round = 0;
  int _total = 5;
  int _countdown = 3;
  String _kind = 'swipe';
  Scenario? _scenario;
  int _seconds = 15;
  int _left = 15;
  Timer? _clock;
  bool _answered = false;
  bool _opponentAnswered = false;
  final Set<String> _tapped = {};
  Map<String, dynamic>? _roundResult;
  Map<String, dynamic>? _finished;
  final List<_FloatingReaction> _floating = [];
  int _reactionKey = 0;
  final List<Map<String, dynamic>> _review = [];
  Timer? _connectGuard;

  bool get _meIsA => _myKey != 'b';
  Map<String, dynamic> get _me => _meIsA ? _a : _b;
  Map<String, dynamic> get _opponent => _meIsA ? _b : _a;
  int get _myScore => _meIsA ? _scoreA : _scoreB;
  int get _theirScore => _meIsA ? _scoreB : _scoreA;

  @override
  void initState() {
    super.initState();
    _client = ref.read(repoProvider).duelClient();
    _start();
  }

  Future<void> _start() async {
    try {
      await _client.connect();
    } catch (_) {
      // The reconnect loop continues; the guard below tells the player if it stays down.
    }
    _sub = _client.watch(widget.duelId).listen(_onEvent);
    // Give the subscription a moment to reach the broker before announcing we are here.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _client.ready(widget.duelId);
    _connectGuard = Timer(const Duration(seconds: 2), () {
      if (mounted && _phase == _Phase.connecting) _client.ready(widget.duelId);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _clock?.cancel();
    _connectGuard?.cancel();
    super.dispose();
  }

  void _onEvent(Map<String, dynamic> e) {
    if (!mounted) return;
    switch (e['type']) {
      case 'state':
        _onState(e);
      case 'countdown':
        _onCountdown((e['ms'] as num).toInt());
      case 'round':
        _onRound(e);
      case 'progress':
        final who = e['player'] as String;
        if (who != _myKey) {
          setState(() => _opponentAnswered = true);
          Sfx.play('tick');
        }
      case 'reaction':
        _showReaction(e['emoji'] as String, e['player'] == _myKey);
      case 'round_result':
        _onResult(e);
      case 'finished':
        _onFinished(e);
    }
  }

  void _onState(Map<String, dynamic> e) {
    final myId = ref.read(appProvider).me?.id;
    final a = Map<String, dynamic>.from(e['a'] as Map);
    final b = Map<String, dynamic>.from(e['b'] as Map);
    setState(() {
      _a = a;
      _b = b;
      _myKey = a['userId'] == myId ? 'a' : (b['userId'] == myId ? 'b' : 'a');
      _scoreA = (a['score'] as num?)?.toInt() ?? _scoreA;
      _scoreB = (b['score'] as num?)?.toInt() ?? _scoreB;
      if (_phase == _Phase.connecting) _phase = _Phase.versus;
    });
  }

  void _onCountdown(int ms) {
    setState(() {
      _phase = _Phase.countdown;
      _countdown = (ms / 1000).ceil();
    });
    Sfx.play('tick');
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
      Sfx.play('tick');
    });
  }

  void _onRound(Map<String, dynamic> e) {
    final scenarios = Map<String, dynamic>.from(e['scenarios'] as Map);
    final locale = ref.read(appProvider).locale;
    final raw = scenarios[locale] ?? scenarios.values.first;
    Sfx.play('whoosh', volume: 0.5);
    setState(() {
      _phase = _Phase.round;
      _round = (e['no'] as num).toInt();
      _total = (e['total'] as num).toInt();
      _kind = e['kind'] as String;
      _scenario = Scenario.fromJson(Map<String, dynamic>.from(raw as Map));
      _seconds = (e['seconds'] as num).toInt();
      _left = _seconds;
      _answered = false;
      _opponentAnswered = false;
      _tapped.clear();
      _roundResult = null;
    });
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 0) {
        t.cancel();
        return;
      }
      setState(() => _left--);
      if (_left <= 3 && !_answered) Sfx.play('tick');
    });
  }

  void _answer({String? verdict, List<String>? flags}) {
    if (_answered) return;
    Sfx.click();
    setState(() => _answered = true);
    _client.answer(widget.duelId, _round, verdict: verdict, flags: flags);
  }

  void _onResult(Map<String, dynamic> e) {
    _clock?.cancel();
    final mine = Map<String, dynamic>.from(e[_myKey ?? 'a'] as Map);
    final a = Map<String, dynamic>.from(e['a'] as Map);
    final b = Map<String, dynamic>.from(e['b'] as Map);
    final solutions = Map<String, dynamic>.from(e['solutions'] as Map);
    final locale = ref.read(appProvider).locale;
    final solution = Map<String, dynamic>.from((solutions[locale] ?? solutions.values.first) as Map);
    final correct = mine['correct'] == true;
    correct ? Sfx.success() : Sfx.error();
    if (!correct) HapticFeedback.heavyImpact();
    setState(() {
      _phase = _Phase.result;
      _scoreA = (a['total'] as num).toInt();
      _scoreB = (b['total'] as num).toInt();
      _roundResult = {'mine': mine, 'solution': solution};
      if (!correct) _review.add({'title': _scenario?.title ?? '', 'explanation': solution['explanation']});
    });
  }

  void _onFinished(Map<String, dynamic> e) {
    _clock?.cancel();
    final winner = e['winner'] as String?;
    final won = winner == _myKey;
    Sfx.play(won ? 'levelup' : 'error');
    setState(() {
      _phase = _Phase.finished;
      _finished = e;
    });
    ref.read(appProvider.notifier).refresh();
  }

  void _showReaction(String emoji, bool mine) {
    final r = _FloatingReaction(_reactionKey++, emoji, mine, Random().nextDouble() * 60 - 30);
    setState(() => _floating.add(r));
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _floating.remove(r));
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _Phase.finished || _phase == _Phase.connecting,
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            Positioned.fill(child: _body(context)),
            for (final r in _floating) _floatingWidget(r),
          ]),
        ),
      ),
    );
  }

  Widget _floatingWidget(_FloatingReaction r) {
    final (icon, color) = _reactions[r.emoji] ?? (Icons.star, K.teal);
    return Positioned(
      key: ValueKey(r.key),
      bottom: 90,
      left: r.mine ? 50 + r.dx : null,
      right: r.mine ? null : 50 + r.dx,
      child: IgnorePointer(
        child: Icon(icon, color: color, size: 46)
            .animate()
            .scale(begin: const Offset(0.4, 0.4), end: const Offset(1.2, 1.2), duration: 240.ms, curve: Curves.easeOutBack)
            .moveY(begin: 0, end: -240, duration: 1400.ms, curve: Curves.easeOut)
            .fadeOut(delay: 900.ms, duration: 500.ms),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return switch (_phase) {
      _Phase.connecting => _connecting(context),
      _Phase.versus || _Phase.countdown => _versus(context),
      _Phase.round => _roundView(context),
      _Phase.result => _resultView(context),
      _Phase.finished => _finishedView(context),
    };
  }

  Widget _connecting(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 14),
        Text(context.l.duelConnecting, style: const TextStyle(color: K.muted)),
      ]),
    );
  }

  Widget _versus(BuildContext context) {
    final l = context.l;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _fighter(_me, K.teal).animate().slideX(begin: -1.2, end: 0, duration: 420.ms, curve: Curves.easeOutBack),
      const SizedBox(height: 18),
      if (_phase == _Phase.countdown)
        Text('$_countdown', key: ValueKey(_countdown), style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 96, color: K.teal))
            .animate()
            .scale(begin: const Offset(1.8, 1.8), end: const Offset(1, 1), duration: 300.ms, curve: Curves.easeOutBack)
      else
        const Text('VS', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 64, color: K.danger)).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
      const SizedBox(height: 18),
      _fighter(_opponent, K.violet).animate().slideX(begin: 1.2, end: 0, duration: 420.ms, curve: Curves.easeOutBack),
      const SizedBox(height: 26),
      if (_phase == _Phase.versus) Text(l.duelWaitingOpponent, style: const TextStyle(color: K.muted)),
    ]);
  }

  Widget _fighter(Map<String, dynamic> p, Color color) {
    final bot = p['bot'] == true;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 22)]),
      child: Row(children: [
        Avatars.of((p['avatar'] as num?)?.toInt() ?? 0, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text((p['name'] as String?) ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 19))),
              if (bot) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.smart_toy_outlined, size: 18, color: K.muted)),
            ]),
            Text('ELO ${(p['elo'] as num?)?.toInt() ?? 1000}', style: const TextStyle(color: K.muted, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _scoreBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: K.surface,
      child: Column(children: [
        Row(children: [
          Avatars.of((_me['avatar'] as num?)?.toInt() ?? 0, size: 34),
          const SizedBox(width: 8),
          Text('$_myScore', style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 24, color: K.teal)),
          Expanded(
            child: Column(children: [
              Text(context.l.duelRound(_round, _total), style: const TextStyle(color: K.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= _total; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 16,
                    height: 5,
                    decoration: BoxDecoration(color: i < _round ? K.teal : (i == _round ? K.warn : K.surface2), borderRadius: BorderRadius.circular(9)),
                  ),
              ]),
            ]),
          ),
          Stack(clipBehavior: Clip.none, children: [
            Row(children: [
              Text('$_theirScore', style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 24, color: K.violet)),
              const SizedBox(width: 8),
              Avatars.of((_opponent['avatar'] as num?)?.toInt() ?? 0, size: 34),
            ]),
            if (_opponentAnswered)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  decoration: const BoxDecoration(color: K.teal, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: Colors.black),
                ).animate().scale(duration: 240.ms, curve: Curves.elasticOut),
              ),
          ]),
        ]),
      ]),
    );
  }

  Widget _reactionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (final e in _reactions.entries)
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              HapticFeedback.selectionClick();
              _client.react(widget.duelId, e.key);
            },
            icon: Icon(e.value.$1, color: e.value.$2, size: 25),
          ),
      ]),
    );
  }

  Widget _roundView(BuildContext context) {
    final l = context.l;
    final s = _scenario;
    if (s == null) return const SizedBox.shrink();
    final flags = _kind == 'flags';
    return Column(children: [
      _scoreBar(),
      TweenAnimationBuilder<double>(
        key: ValueKey(_round),
        tween: Tween(begin: 1, end: 0),
        duration: Duration(seconds: _seconds),
        builder: (context, v, _) => LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: K.surface2, color: v < 0.25 ? K.danger : K.teal),
      ),
      Expanded(
        child: flags
            ? Column(children: [
                Padding(padding: const EdgeInsets.all(8), child: Text(l.flagsHint, style: const TextStyle(color: K.muted, fontSize: 13))),
                Expanded(
                  child: MailSim(
                    key: ValueKey('flags$_round'),
                    s: s,
                    props: SimProps(selected: _tapped, onToggle: _answered ? (_) {} : (t) => setState(() => _tapped.contains(t) ? _tapped.remove(t) : _tapped.add(t))),
                  ),
                ),
              ])
            : Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: ScenarioCard(key: ValueKey('card$_round'), s: s).animate().scaleXY(begin: 0.9, end: 1, duration: 220.ms, curve: Curves.easeOutBack)),
      ),
      if (_answered)
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.hourglass_top, size: 18, color: K.muted),
            const SizedBox(width: 8),
            Text(_opponentAnswered ? l.duelBothDone : l.duelWaitOther, style: const TextStyle(color: K.muted)),
          ]),
        )
      else if (flags)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _answer(flags: _tapped.toList()), child: Text(l.flagsSubmit(_tapped.length)))),
        )
      else
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Row(children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: K.danger, foregroundColor: Colors.white, minimumSize: const Size(48, 58)),
                onPressed: () => _answer(verdict: 'attack'),
                icon: const Icon(Icons.phishing),
                label: Text(l.swipePhishing),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(48, 58)),
                onPressed: () => _answer(verdict: 'legit'),
                icon: const Icon(Icons.verified_outlined),
                label: Text(l.swipeGenuine),
              ),
            ),
          ]),
        ),
      _reactionBar(),
    ]);
  }

  Widget _resultView(BuildContext context) {
    final l = context.l;
    final r = _roundResult;
    if (r == null) return const SizedBox.shrink();
    final mine = r['mine'] as Map<String, dynamic>;
    final solution = r['solution'] as Map<String, dynamic>;
    final ok = mine['correct'] == true;
    final attack = solution['isAttack'] == true;
    return Column(children: [
      _scoreBar(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Icon(ok ? Icons.check_circle : Icons.cancel, size: 74, color: ok ? K.teal : K.danger).animate().scale(duration: 360.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text(ok ? '+${(mine['points'] as num).toInt()}' : l.duelWrong, textAlign: TextAlign.center, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 38, color: ok ? K.teal : K.danger)),
            const SizedBox(height: 6),
            Text(attack ? l.duelWasAttack : l.duelWasGenuine, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Text(solution['explanation'] as String, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, height: 1.4, fontSize: 14.5)),
          ]),
        ),
      ),
      _reactionBar(),
    ]);
  }

  Widget _finishedView(BuildContext context) {
    final l = context.l;
    final f = _finished!;
    final winner = f['winner'] as String?;
    final won = winner == _myKey;
    final draw = winner == null;
    final mine = Map<String, dynamic>.from(f[_myKey ?? 'a'] as Map);
    final delta = (mine['eloDelta'] as num).toInt();
    final title = draw ? l.duelDraw : (won ? l.duelWon : l.duelLost);
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Mascot(mood: won ? MascotMood.cheering : (draw ? MascotMood.neutral : MascotMood.worried), size: 140)),
        Text(title, textAlign: TextAlign.center, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 38, color: won ? K.teal : (draw ? K.ink : K.warn))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _scoreCell(_me, _myScore, K.teal)),
          const SizedBox(width: 10),
          Expanded(child: _scoreCell(_opponent, _theirScore, K.violet)),
        ]),
        const SizedBox(height: 12),
        if (delta != 0)
          Center(child: Pill(icon: delta > 0 ? Icons.trending_up : Icons.trending_down, label: 'ELO ${delta > 0 ? '+' : ''}$delta → ${(mine['elo'] as num).toInt()}', color: delta > 0 ? K.teal : K.warn)),
        if (_review.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(l.duelReview, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final r in _review)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: K.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(r['explanation'] as String, style: const TextStyle(color: K.muted, fontSize: 13.5, height: 1.35)),
                ]),
              ),
            ),
        ],
        const SizedBox(height: 18),
        FilledButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
      ]),
      if (won) const Positioned.fill(child: Confetti(count: 150)),
    ]);
  }

  Widget _scoreCell(Map<String, dynamic> p, int score, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.6))),
      child: Column(children: [
        Avatars.of((p['avatar'] as num?)?.toInt() ?? 0, size: 42),
        const SizedBox(height: 4),
        Text((p['name'] as String?) ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text('$score', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 30, color: color)),
      ]),
    );
  }
}
