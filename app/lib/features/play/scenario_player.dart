import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/confetti.dart';
import '../../effects/hacked_overlay.dart';
import '../../effects/mascot.dart';
import '../../simulators/common.dart';
import '../../simulators/scenario_view.dart';

/// A genuine message cannot hack anybody: being wrong about one means seeing attacks that are not there.
HackKind hackKindOf(Evaluation e) {
  if (!e.attack) return HackKind.paranoid;
  return e.outcome == 'HACKED' ? HackKind.attack : HackKind.missed;
}

/// One scenario from first look to debrief: decide first, then learn. Used by shifts, reviews and lessons.
class ScenarioPlayer extends ConsumerStatefulWidget {
  const ScenarioPlayer({super.key, required this.scenario, required this.submit, required this.onNext, required this.nextLabel, this.simple = false, this.mailTour});

  final Scenario scenario;
  final Future<Evaluation> Function(String action, int ms) submit;
  final VoidCallback onNext;
  final String nextLabel;
  final bool simple;
  final MailTourKeys? mailTour;

  @override
  ConsumerState<ScenarioPlayer> createState() => _ScenarioPlayerState();
}

class _ScenarioPlayerState extends ConsumerState<ScenarioPlayer> {
  final Stopwatch _watch = Stopwatch()..start();
  Evaluation? _result;
  bool _busy = false;
  bool _confetti = false;

  Future<void> _act(String action) async {
    if (_busy || _result != null) return;
    setState(() => _busy = true);
    Sfx.click();
    Sfx.stopLoop();
    Evaluation e;
    try {
      e = await widget.submit(action, _watch.elapsedMilliseconds);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l.errorGeneric)));
      }
      return;
    }
    if (e.correct) {
      Sfx.success();
    } else {
      // Every mistake gets a reaction, so that it sticks. Simple mode keeps it short: no fake ransom screen for someone's grandmother.
      await ref.read(hackProvider.notifier).play(kind: hackKindOf(e), short: widget.simple);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = e;
      _confetti = e.outcome == 'CORRECT' && e.attack;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Stack(children: [
      Positioned.fill(
        child: ScenarioView(
          key: ValueKey(widget.scenario.id),
          s: widget.scenario,
          props: SimProps(onAction: r == null ? _act : null, reveal: r?.redFlags, simple: widget.simple, mailTour: widget.mailTour),
        ),
      ),
      if (_busy && r == null) const Positioned.fill(child: ColoredBox(color: Color(0x33000000), child: Center(child: CircularProgressIndicator()))),
      if (r != null) Align(alignment: Alignment.bottomCenter, child: _Debrief(result: r, nextLabel: widget.nextLabel, onNext: widget.onNext)),
      if (_confetti) const Positioned.fill(child: Confetti()),
    ]);
  }
}

class _Debrief extends StatelessWidget {
  const _Debrief({required this.result, required this.nextLabel, required this.onNext});
  final Evaluation result;
  final String nextLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final r = result;
    final (title, color, icon, mood) = switch (r.outcome) {
      'CORRECT' => (r.attack ? (r.reported ? l.resultReported : l.resultWellDone) : l.resultGenuine, K.teal, Icons.verified_user, MascotMood.cheering),
      'SAFE' => (l.resultSafe, K.warn, Icons.shield_outlined, MascotMood.happy),
      'HACKED' => (l.resultHacked, K.danger, Icons.gpp_bad, MascotMood.hooked),
      'FALSE_ALARM' => (l.resultFalseAlarm, K.warn, Icons.notifications_off_outlined, MascotMood.worried),
      _ => r.attack ? (l.resultMissed, K.warn, Icons.help_outline, MascotMood.worried) : (l.resultFalseAlarm, K.warn, Icons.notifications_off_outlined, MascotMood.worried),
    };
    final flags = r.redFlags;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.62),
      child: Container(
        decoration: BoxDecoration(
          color: K.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: color, width: 3)),
          boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 24, offset: Offset(0, -6))],
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Mascot(mood: mood, size: 58),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(title, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 19, color: color))),
                        ]),
                        const SizedBox(height: 5),
                        Wrap(spacing: 6, children: [
                          Pill(icon: Icons.bolt, label: '+${r.xp} XP', color: K.warn),
                          if (r.coins > 0) Pill(icon: Icons.toll, label: '+${r.coins}', color: K.blue),
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(r.explanation, style: const TextStyle(fontSize: 15, height: 1.42)),
                  if (flags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(l.redFlagsTitle(flags.length), style: const TextStyle(fontWeight: FontWeight.w700, color: K.danger, fontSize: 13.5)),
                    const SizedBox(height: 6),
                    for (final (i, f) in flags.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.flag, size: 15, color: K.danger)),
                          const SizedBox(width: 7),
                          Expanded(child: Text(f.hint, style: const TextStyle(fontSize: 14, height: 1.38))),
                        ]).animate().fadeIn(delay: (120 * i + 150).ms).slideX(begin: 0.04, end: 0),
                      ),
                  ],
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: FilledButton(onPressed: onNext, autofocus: true, child: Text(nextLabel)),
            ),
          ]),
        ),
      ).animate().slideY(begin: 0.4, end: 0, duration: 320.ms, curve: Curves.easeOutCubic).fadeIn(duration: 200.ms),
    );
  }
}

/// A sequence of scenarios with its own frame. Reviews and module lessons use this.
class ScenarioRun extends ConsumerStatefulWidget {
  const ScenarioRun({super.key, required this.title, required this.load, required this.context, required this.submit, this.onFinished, this.intro, this.theory, this.solvedBefore = 0, this.total});

  final String title;
  final Future<List<Scenario>> Function() load;
  final String context;
  final Future<Evaluation> Function(String scenarioId, String action, int ms) submit;
  final FutureOr<void> Function()? onFinished;
  final Widget? intro;

  /// Background reading, only for whoever asks for it: before the first question, or at any point from the app bar.
  final String? theory;

  /// For a lesson: how much of it was already solved, so the bar continues where the player left off.
  final int solvedBefore;
  final int? total;

  @override
  ConsumerState<ScenarioRun> createState() => _ScenarioRunState();
}

class _ScenarioRunState extends ConsumerState<ScenarioRun> {
  List<Scenario>? _list;
  int _i = 0;
  int _correct = 0;
  bool _introDone = false;
  bool _theoryOpen = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    widget.load().then((v) {
      if (mounted) setState(() => _list = v);
    }, onError: (Object e) {
      if (mounted) setState(() => _error = e);
    });
  }

  /// Plays what is still unsolved once more.
  void _retry() {
    setState(() {
      _list = null;
      _i = 0;
      _correct = 0;
    });
    _load();
  }

  double _progress(int listLength) {
    final total = widget.total;
    if (total == null || total == 0 || widget.solvedBefore >= total) return _i / listLength;
    return ((widget.solvedBefore + _correct) / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final list = _list;
    Widget body;
    if (_error != null) {
      body = Center(child: Text(l.errorGeneric));
    } else if (list == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (list.isEmpty) {
      body = _Empty();
    } else if (widget.intro != null && !_introDone) {
      body = Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              widget.intro!,
              if (widget.theory != null) ...[
                const SizedBox(height: 14),
                if (_theoryOpen)
                  Text(widget.theory!, style: const TextStyle(fontSize: 16, height: 1.5)).animate().fadeIn(duration: 220.ms)
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _theoryOpen = true),
                      icon: const Icon(Icons.menu_book_outlined, size: 18),
                      label: Text(l.theoryRead),
                    ),
                  ),
              ],
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _introDone = true), child: Text(l.lessonStart))),
        ),
      ]);
    } else if (_i >= list.length) {
      body = _Done(correct: _correct, total: list.length, onRetry: widget.total != null && _correct < list.length ? _retry : null);
    } else {
      final s = list[_i];
      body = Column(children: [
        LinearProgressIndicator(value: _progress(list.length), minHeight: 4, backgroundColor: K.surface2),
        Expanded(
          child: ScenarioPlayer(
            key: ValueKey('${s.id}-$_i'),
            scenario: s,
            submit: (a, ms) async {
              final e = await widget.submit(s.id, a, ms);
              if (e.correct) setState(() => _correct++);
              return e;
            },
            onNext: () {
              setState(() => _i++);
              if (_i >= list.length) widget.onFinished?.call();
            },
            nextLabel: _i + 1 < list.length ? l.next : l.finish,
          ),
        ),
      ]);
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        if (widget.theory != null && (widget.intro == null || _introDone))
          IconButton(
            tooltip: l.theoryTitle,
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: K.surface,
              isScrollControlled: true,
              builder: (_) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Text(widget.theory!, style: const TextStyle(fontSize: 16, height: 1.5)))),
            ),
          ),
      ]),
      body: body,
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Mascot(mood: MascotMood.happy, size: 130),
          const SizedBox(height: 12),
          Text(l.reviewEmpty, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16)),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: Text(l.back)),
        ]),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.correct, required this.total, this.onRetry});
  final int correct;
  final int total;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Stack(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Mascot(mood: MascotMood.cheering, size: 140),
            const SizedBox(height: 12),
            Text(l.runDone(correct, total), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 22),
            if (onRetry != null) ...[
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.replay), label: Text(l.moduleRetry)),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: Text(l.back)),
            ] else
              FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: Text(l.back)),
          ]),
        ),
      ),
      if (correct * 2 >= total) const Positioned.fill(child: Confetti()),
    ]);
  }
}
