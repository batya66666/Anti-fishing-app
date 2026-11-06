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
import '../../data/models.dart';
import '../../effects/confetti.dart';
import '../../effects/hacked_overlay.dart';
import '../../effects/mascot.dart';
import '../../simulators/scenario_view.dart';
import '../play/scenario_player.dart';

/// 20 cards, 60 seconds. Left: phishing. Right: genuine. Made for the queue in the Mensa.
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> with TickerProviderStateMixin {
  List<Scenario>? _deck;
  int _i = 0;
  int _seconds = 60;
  int _score = 0;
  int _correct = 0;
  int _combo = 0;
  bool _over = false;
  bool _hacked = false;
  Timer? _timer;
  Offset _drag = Offset.zero;
  bool _flying = false;
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  Animation<Offset>? _flyAnim;
  bool? _lastOk;
  final Stopwatch _cardWatch = Stopwatch();
  final List<(Scenario, Evaluation)> _wrong = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final deck = await ref.read(repoProvider).swipeDeck();
      if (!mounted) return;
      setState(() => _deck = deck);
      _cardWatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_hacked) return; // the clock waits while your screen falls apart
        if (_seconds <= 1) {
          _end();
        } else {
          setState(() => _seconds--);
          if (_seconds <= 5) Sfx.play('tick');
        }
      });
    } catch (_) {
      if (mounted) setState(() => _deck = const []);
    }
  }

  void _again() {
    Sfx.click();
    _timer?.cancel();
    setState(() {
      _deck = null;
      _i = 0;
      _seconds = 60;
      _score = 0;
      _correct = 0;
      _combo = 0;
      _over = false;
      _lastOk = null;
      _drag = Offset.zero;
      _wrong.clear();
    });
    _load();
  }

  void _end() {
    _timer?.cancel();
    setState(() => _over = true);
    Sfx.success();
    ref.read(appProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fly.dispose();
    super.dispose();
  }

  void _decide(String verdict, double width) {
    final deck = _deck;
    if (deck == null || _flying || _i >= deck.length || _over) return;
    final s = deck[_i];
    final ms = _cardWatch.elapsedMilliseconds;
    _cardWatch
      ..reset()
      ..start();
    HapticFeedback.selectionClick();
    Sfx.play('whoosh', volume: 0.4);

    // The next card appears at once; the verdict lands a moment later from the server.
    ref.read(repoProvider).practice(scenarioId: s.id, context: 'swipe', action: verdict, ms: ms).then((e) {
      if (!mounted) return;
      setState(() {
        _lastOk = e.correct;
        if (e.correct) {
          _correct++;
          _combo++;
          _score += e.points + min(_combo, 5) * 5;
        } else {
          _combo = 0;
          _wrong.add((s, e));
        }
      });
      if (e.correct) {
        HapticFeedback.lightImpact();
        Sfx.play('click', volume: 0.6);
      } else {
        HapticFeedback.heavyImpact();
        _hacked = true;
        ref.read(hackProvider.notifier).play(kind: hackKindOf(e), short: true).whenComplete(() => _hacked = false);
      }
    });

    setState(() => _flying = true);
    final end = Offset((verdict == 'attack' ? -1 : 1) * width * 1.3, _drag.dy);
    _flyAnim = Tween<Offset>(begin: _drag, end: end).animate(CurvedAnimation(parent: _fly, curve: Curves.easeIn));
    _fly.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _flying = false;
        _drag = Offset.zero;
        _i++;
        if (_i >= deck.length) _end();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final deck = _deck;
    if (deck == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_over) return _results(context, deck);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 16, 4),
            child: Row(children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
              Expanded(child: Text('${_i + 1} / ${deck.length}', style: const TextStyle(color: K.muted, fontWeight: FontWeight.w600))),
              if (_combo >= 2) Padding(padding: const EdgeInsets.only(right: 8), child: Pill(icon: Icons.local_fire_department, label: 'x$_combo', color: K.warn)),
              Text('$_score', style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 22, color: K.teal)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(value: _seconds / 60, minHeight: 7, backgroundColor: K.surface2, color: _seconds <= 10 ? K.danger : K.teal),
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Stack(children: [
                  if (_i + 1 < deck.length)
                    Positioned.fill(
                      child: Transform.scale(scale: 0.95, child: Opacity(opacity: 0.55, child: ScenarioCard(key: ValueKey('n${deck[_i + 1].id}'), s: deck[_i + 1]))),
                    ),
                  if (_i < deck.length) Positioned.fill(child: _topCard(deck[_i], c.maxWidth)),
                  if (_lastOk != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Icon(_lastOk! ? Icons.check_circle : Icons.cancel, color: _lastOk! ? K.teal : K.danger, size: 42)
                          .animate(key: ValueKey('$_i$_lastOk'))
                          .scale(duration: 180.ms, curve: Curves.easeOutBack)
                          .fadeOut(delay: 320.ms, duration: 220.ms),
                    ),
                ]),
              );
            }),
          ),
          LayoutBuilder(builder: (context, c) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: K.danger, foregroundColor: Colors.white, minimumSize: const Size(48, 60)),
                    onPressed: () => _decide('attack', c.maxWidth),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l.swipePhishing),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(48, 60)),
                    onPressed: () => _decide('legit', c.maxWidth),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l.swipeGenuine),
                  ),
                ),
              ]),
            );
          }),
        ]),
      ),
    );
  }

  Widget _topCard(Scenario s, double width) {
    final l = context.l;
    return AnimatedBuilder(
      animation: _fly,
      builder: (context, child) {
        final offset = _flying && _flyAnim != null ? _flyAnim!.value : _drag;
        final t = (offset.dx / width).clamp(-1.0, 1.0);
        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: t * 0.32,
            child: Stack(children: [
              Positioned.fill(child: child!),
              if (t.abs() > 0.06)
                Positioned(
                  top: 54,
                  left: t > 0 ? 18 : null,
                  right: t < 0 ? 18 : null,
                  child: Opacity(
                    opacity: (t.abs() * 3).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: t > 0 ? -0.22 : 0.22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(border: Border.all(color: t > 0 ? const Color(0xFF12A594) : const Color(0xFFD92D3F), width: 3), borderRadius: BorderRadius.circular(8)),
                        child: Text(t > 0 ? l.swipeGenuine : l.swipePhishing, style: TextStyle(color: t > 0 ? const Color(0xFF12A594) : const Color(0xFFD92D3F), fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 22)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        );
      },
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _drag += d.delta),
        onPanEnd: (d) {
          final fast = d.velocity.pixelsPerSecond.dx.abs() > 700;
          if (_drag.dx.abs() > width * 0.26 || fast) {
            final right = fast ? d.velocity.pixelsPerSecond.dx > 0 : _drag.dx > 0;
            _decide(right ? 'legit' : 'attack', width);
          } else {
            setState(() => _drag = Offset.zero);
          }
        },
        child: ScenarioCard(key: ValueKey(s.id), s: s),
      ),
    );
  }

  Widget _results(BuildContext context, List<Scenario> deck) {
    final l = context.l;
    final seen = max(_i, 1);
    return Scaffold(
      body: Stack(children: [
        SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: Mascot(mood: _correct * 4 >= seen * 3 ? MascotMood.cheering : MascotMood.happy, size: 120)),
            Text('$_score', textAlign: TextAlign.center, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 56, color: K.teal)),
            Text(l.swipeResult(_correct, _i), textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16)),
            const SizedBox(height: 18),
            for (final (s, e) in _wrong.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: K.line)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(e.explanation, style: const TextStyle(color: K.muted, fontSize: 13.5, height: 1.35)),
                  ]),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _again, icon: const Icon(Icons.replay), label: Text(l.swipeAgain)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => context.pop(), child: Text(l.backHome)),
          ]),
        ),
        if (_correct * 4 >= seen * 3) const Positioned.fill(child: Confetti()),
      ]),
    );
  }
}
