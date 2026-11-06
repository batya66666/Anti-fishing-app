import 'dart:async';

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
import '../../effects/mascot.dart';
import '../../effects/tour.dart';
import '../../simulators/common.dart';
import '../../simulators/scenario_view.dart';
import '../play/scenario_player.dart';
import 'shift_report.dart';

/// The daily working shift: messages keep arriving in the inbox, and calls interrupt you, as in real life.
class ShiftScreen extends ConsumerStatefulWidget {
  const ShiftScreen({super.key});

  @override
  ConsumerState<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends ConsumerState<ShiftScreen> {
  TodayShift? _shift;
  Object? _error;
  int _arrived = 0;
  Timer? _arrivals;
  Scenario? _open;
  final Map<String, Evaluation> _results = {};
  final Set<String> _alreadyDone = {};
  int _levelBefore = 1;
  final _inboxKey = GlobalKey();
  final _pillKey = GlobalKey();
  final _mailTour = MailTourKeys();
  bool _touring = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repoProvider);
    _levelBefore = ref.read(appProvider).me?.level ?? 1;
    try {
      final shift = await repo.today();
      if (!mounted) return;
      setState(() {
        _shift = shift;
        _alreadyDone.addAll(shift.answered);
        _arrived = _alreadyDone.length;
      });
      _arrivals = Timer.periodic(const Duration(milliseconds: 1300), (t) {
        if (_arrived >= shift.scenarios.length) {
          t.cancel();
          return;
        }
        final next = shift.scenarios[_arrived];
        setState(() => _arrived++);
        Sfx.play('notify', volume: 0.45);
        HapticFeedback.lightImpact();
        // A ringing phone does not wait until you are done reading.
        if (_open == null && _answeredCount >= 2 && _interrupts(next)) _openScenario(next);
      });
      Timer(const Duration(milliseconds: 250), () {
        if (mounted && _arrived == 0 && shift.scenarios.isNotEmpty) setState(() => _arrived = 1);
      });
      Timer(const Duration(milliseconds: 900), _inboxTour);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _inboxTour() async {
    final app = ref.read(appProvider.notifier);
    if (!mounted || _touring || _open != null || app.tourSeen('shift')) return;
    _touring = true;
    final l = context.l;
    await runTour(context, [
      TourStep(target: _inboxKey, title: l.tourInboxTitle, body: l.tourInboxBody),
      TourStep(target: _pillKey, title: l.tourProgressTitle, body: l.tourProgressBody, mood: MascotMood.cheering),
    ]);
    _touring = false;
    await app.markTour('shift');
  }

  Future<void> _mailTourRun() async {
    final app = ref.read(appProvider.notifier);
    if (!mounted || _touring || app.tourSeen('mail')) return;
    _touring = true;
    final l = context.l;
    await runTour(context, [
      TourStep(target: _mailTour.sender, title: l.tourSenderTitle, body: l.tourSenderBody, mood: MascotMood.neutral),
      TourStep(target: _mailTour.content, title: l.tourContentTitle, body: l.tourContentBody, mood: MascotMood.worried),
      TourStep(target: _mailTour.actions, title: l.tourActionsTitle, body: l.tourActionsBody, mood: MascotMood.cheering),
    ]);
    _touring = false;
    await app.markTour('mail');
  }

  bool _interrupts(Scenario s) => (s.type == 'call' || s.type == 'push') && !_isDone(s.id);
  bool _isDone(String id) => _results.containsKey(id) || _alreadyDone.contains(id);
  int get _answeredCount => _results.length + _alreadyDone.length;

  void _openScenario(Scenario s) {
    if (_isDone(s.id)) return;
    Sfx.click();
    setState(() => _open = s);
    if (s.type == 'email') WidgetsBinding.instance.addPostFrameCallback((_) => _mailTourRun());
  }

  void _closeScenario() {
    final shift = _shift!;
    setState(() => _open = null);
    if (_answeredCount >= shift.scenarios.length) {
      _finish();
      return;
    }
    // Calls and sign-in prompts that came in while you were busy now claim your attention.
    final waiting = shift.scenarios.take(_arrived).where(_interrupts);
    if (_answeredCount >= 2 && waiting.isNotEmpty) {
      Timer(const Duration(milliseconds: 700), () {
        if (mounted && _open == null) _openScenario(waiting.first);
      });
    }
  }

  Future<void> _finish() async {
    final shift = _shift!;
    _arrivals?.cancel();
    await ref.read(appProvider.notifier).refresh();
    if (!mounted) return;
    final me = ref.read(appProvider).me;
    context.pushReplacement(
      '/shift/report',
      extra: ShiftSummary(scenarios: shift.scenarios, results: Map.of(_results), levelBefore: _levelBefore, levelAfter: me?.level ?? _levelBefore),
    );
  }

  @override
  void dispose() {
    _arrivals?.cancel();
    Sfx.stopLoop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final shift = _shift;
    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.errorGeneric)));
    }
    if (shift == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final open = _open;
    if (open != null) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: ScenarioPlayer(
              key: ValueKey(open.id),
              scenario: open,
              simple: ref.read(appProvider).simple,
              mailTour: _mailTour,
              submit: (action, ms) async {
                final r = await ref.read(repoProvider).act(shift.id, open.id, action, ms);
                setState(() => _results[open.id] = r.evaluation);
                return r.evaluation;
              },
              onNext: _closeScenario,
              nextLabel: _answeredCount >= shift.scenarios.length ? l.shiftFinish : l.backToInbox,
            ),
          ),
        ),
      );
    }
    final protectedCount = _results.values.where((e) => e.correct).length;
    final total = shift.scenarios.length;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
            child: Row(children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
              Expanded(child: Text(l.shiftTitle, style: Theme.of(context).textTheme.titleLarge)),
              KeyedSubtree(key: _pillKey, child: Pill(icon: Icons.shield_outlined, label: '$protectedCount/$total', color: K.teal)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(value: _answeredCount / total, minHeight: 6, backgroundColor: K.surface2, color: K.teal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: Row(children: [
              const Mascot(mood: MascotMood.neutral, size: 40),
              const SizedBox(width: 6),
              Expanded(child: Text(l.shiftHint, style: const TextStyle(color: K.muted, fontSize: 13, height: 1.3))),
            ]),
          ),
          Expanded(
            key: _inboxKey,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: _arrived,
              itemBuilder: (context, i) {
                final s = shift.scenarios[i];
                final done = _isDone(s.id);
                return _InboxRow(scenario: s, result: _results[s.id], done: done, onTap: done ? null : () => _openScenario(s))
                    .animate(key: ValueKey(s.id))
                    .fadeIn(duration: 260.ms)
                    .slideY(begin: -0.25, end: 0, duration: 260.ms, curve: Curves.easeOutCubic);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.scenario, required this.result, required this.done, required this.onTap});
  final Scenario scenario;
  final Evaluation? result;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final r = result;
    final (statusIcon, statusColor) = r == null
        ? (null, K.muted)
        : switch (r.outcome) {
            'CORRECT' => (Icons.check_circle, K.teal),
            'SAFE' => (Icons.shield_outlined, K.warn),
            'HACKED' => (Icons.gpp_bad, K.danger),
            _ => (Icons.error_outline, K.warn),
          };
    final urgent = !done && (scenario.type == 'call' || scenario.type == 'push');
    final snippet = scenario.type == 'call' ? l.inboxCall : scenario.snippet;
    Widget icon = Icon(channelIcon(scenario.type), color: urgent ? K.danger : K.teal, size: 22);
    if (urgent) icon = icon.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.25, duration: 420.ms);
    return Opacity(
      opacity: done ? 0.62 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: K.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: urgent ? K.danger.withValues(alpha: 0.6) : K.line)),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: K.surface2, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(scenario.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: done ? FontWeight.w500 : FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(snippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 13)),
                  ]),
                ),
                const SizedBox(width: 6),
                if (statusIcon != null)
                  Icon(statusIcon, color: statusColor, size: 22)
                else if (!done)
                  Container(width: 9, height: 9, decoration: const BoxDecoration(color: K.teal, shape: BoxShape.circle))
                else
                  const Icon(Icons.check, color: K.muted, size: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
