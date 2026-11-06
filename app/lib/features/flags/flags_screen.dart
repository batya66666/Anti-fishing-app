import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/hacked_overlay.dart';
import '../../effects/mascot.dart';
import '../../simulators/common.dart';
import '../../simulators/mail_sim.dart';

/// Spot the red flags: tap everything suspicious in a message. The most instructive mode.
class FlagsScreen extends ConsumerStatefulWidget {
  const FlagsScreen({super.key});

  @override
  ConsumerState<FlagsScreen> createState() => _FlagsScreenState();
}

class _FlagsScreenState extends ConsumerState<FlagsScreen> {
  List<Scenario>? _deck;
  int _i = 0;
  final Set<String> _tapped = {};
  Evaluation? _result;
  int _points = 0;
  bool _busy = false;
  final Stopwatch _watch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    ref.read(repoProvider).flagsDeck().then((d) {
      if (mounted) setState(() => _deck = d);
    });
  }

  void _again() {
    Sfx.click();
    setState(() {
      _deck = null;
      _i = 0;
      _points = 0;
      _tapped.clear();
      _result = null;
    });
    _load();
  }

  Future<void> _submit() async {
    final s = _deck![_i];
    setState(() => _busy = true);
    final e = await ref.read(repoProvider).practice(scenarioId: s.id, context: 'flags', flags: _tapped.toList(), ms: _watch.elapsedMilliseconds);
    if (e.correct) {
      Sfx.success();
    } else {
      await ref.read(hackProvider.notifier).play(kind: HackKind.missed, short: true);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = e;
      _points += e.points;
    });
  }

  void _next() {
    Sfx.click();
    setState(() {
      _i++;
      _tapped.clear();
      _result = null;
      _watch
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final deck = _deck;
    if (deck == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_i >= deck.length) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Mascot(mood: MascotMood.cheering, size: 140),
              const SizedBox(height: 10),
              Text('$_points', style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 56, color: K.teal)),
              Text(l.flagsDone, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16)),
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: _again, icon: const Icon(Icons.replay), label: Text(l.flagsAgain)),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => context.pop(), child: Text(l.backHome)),
            ]),
          ),
        ),
      );
    }
    final s = deck[_i];
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l.modeFlags), actions: [Padding(padding: const EdgeInsets.only(right: 14), child: Center(child: Pill(icon: Icons.bolt, label: '$_points', color: K.warn)))]),
      body: SafeArea(
        child: Column(children: [
          if (r == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l.flagsHint, style: const TextStyle(color: K.muted, fontSize: 13.5)),
            ),
          Expanded(
            child: MailSim(
              key: ValueKey('${s.id}${r != null}'),
              s: s,
              props: r == null
                  ? SimProps(selected: _tapped, onToggle: (t) => setState(() => _tapped.contains(t) ? _tapped.remove(t) : _tapped.add(t)))
                  : SimProps(reveal: r.redFlags),
            ),
          ),
          Container(
            color: K.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: r == null
                ? SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _busy ? null : _submit, child: Text(l.flagsSubmit(_tapped.length))),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                    Text(l.flagsResult(r.flagsFound, r.flagsFound + r.flagsMissed, r.flagsWrong), style: TextStyle(fontWeight: FontWeight.w700, color: r.correct ? K.teal : K.warn)),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 170),
                      child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          for (final f in r.redFlags)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.flag, color: K.danger, size: 14)),
                                const SizedBox(width: 6),
                                Expanded(child: Text(f.hint, style: const TextStyle(fontSize: 13.5, height: 1.35))),
                              ]),
                            ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _next, child: Text(_i + 1 < deck.length ? l.next : l.finish)),
                  ]),
          ),
        ]),
      ),
    );
  }
}
