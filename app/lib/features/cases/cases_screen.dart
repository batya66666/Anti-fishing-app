import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../effects/confetti.dart';
import '../../effects/hacked_overlay.dart';
import '../../effects/mascot.dart';
import '../../simulators/scenario_view.dart';

final _casesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) => ref.watch(repoProvider).cases());

class CasesScreen extends ConsumerWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final cases = ref.watch(_casesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.modeCases)),
      body: cases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l.errorGeneric)),
        data: (list) => ListView(padding: const EdgeInsets.all(16), children: [
          Text(l.casesIntro, style: const TextStyle(color: K.muted, height: 1.4)),
          const SizedBox(height: 14),
          for (final c in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: K.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Sfx.click();
                    context.push('/cases/${c['id']}');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: K.line)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Pill(icon: Icons.folder_outlined, label: '${c['company']} ${c['year']}', color: K.warn),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: K.muted),
                      ]),
                      const SizedBox(height: 8),
                      Text(c['title'] as String, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 5),
                      Text(c['summary'] as String, style: const TextStyle(color: K.muted, height: 1.38, fontSize: 14)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Play through a real incident as the person who could have stopped it.
class CasePlayerScreen extends ConsumerStatefulWidget {
  const CasePlayerScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<CasePlayerScreen> createState() => _CasePlayerScreenState();
}

class _CasePlayerScreenState extends ConsumerState<CasePlayerScreen> {
  int _step = 0;
  Map<String, dynamic>? _chosen;
  bool? _stopped;
  bool _showEnd = false;

  Future<void> _choose(Map<String, dynamic> option, int steps) async {
    Sfx.click();
    final stops = option['stops'] == true;
    stops ? Sfx.success() : Sfx.error();
    setState(() {
      _chosen = option;
      if (stops) _stopped = true;
    });
  }

  Future<void> _continue(int steps) async {
    if (_stopped == true) {
      setState(() => _showEnd = true);
      return;
    }
    if (_step + 1 >= steps) {
      // Nobody stopped it: the attack goes through, exactly as it did in reality.
      setState(() => _stopped = false);
      await ref.read(hackProvider.notifier).play();
      if (mounted) setState(() => _showEnd = true);
      return;
    }
    setState(() {
      _step++;
      _chosen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cases = ref.watch(_casesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.modeCases)),
      body: cases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l.errorGeneric)),
        data: (list) {
          final c = list.firstWhere((e) => e['id'] == widget.id);
          final steps = (c['steps'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          return _showEnd ? _end(context, c) : _stepView(context, c, steps);
        },
      ),
    );
  }

  Widget _stepView(BuildContext context, Map<String, dynamic> c, List<Map<String, dynamic>> steps) {
    final l = context.l;
    final s = steps[_step];
    final options = (s['options'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final chosen = _chosen;
    return ListView(key: ValueKey(_step), padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Pill(icon: Icons.folder_outlined, label: '${c['company']} ${c['year']}', color: K.warn),
        const Spacer(),
        Text('${_step + 1} / ${steps.length}', style: const TextStyle(color: K.muted, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      Text(s['narration'] as String, style: const TextStyle(fontSize: 16.5, height: 1.45)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: K.simBg, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(channelIcon(s['channel'] as String), color: K.simMuted, size: 20),
          const SizedBox(height: 8),
          Text(s['message'] as String, style: const TextStyle(color: K.simInk, fontSize: 14.5, height: 1.45)),
        ]),
      ).animate().fadeIn().slideY(begin: 0.05, end: 0),
      const SizedBox(height: 14),
      Text(s['question'] as String, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (chosen == null)
        for (final o in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
              onPressed: () => _choose(o, steps.length),
              child: Text(o['label'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)),
            ),
          )
      else ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: chosen['stops'] == true ? K.tealDim : K.dangerDim,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: chosen['stops'] == true ? K.teal : K.danger),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(chosen['stops'] == true ? l.caseStopped : l.caseContinues, style: TextStyle(fontWeight: FontWeight.w700, color: chosen['stops'] == true ? K.teal : K.danger)),
            const SizedBox(height: 4),
            Text(chosen['feedback'] as String, style: const TextStyle(height: 1.4)),
          ]),
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        FilledButton(onPressed: () => _continue(steps.length), child: Text(l.next)),
      ],
    ]);
  }

  Widget _end(BuildContext context, Map<String, dynamic> c) {
    final l = context.l;
    final stopped = _stopped == true;
    final timeline = (c['timeline'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final sources = List<String>.from(c['sources'] as List);
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Mascot(mood: stopped ? MascotMood.cheering : MascotMood.worried, size: 110)),
        Text(stopped ? l.caseWinTitle : l.caseLoseTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(l.caseReality, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final (i, t) in timeline.indexed)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Column(children: [
                Container(width: 13, height: 13, decoration: const BoxDecoration(color: K.danger, shape: BoxShape.circle)),
                if (i < timeline.length - 1) Expanded(child: Container(width: 2, color: K.line)),
              ]),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['when'] as String, style: const TextStyle(color: K.danger, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(t['what'] as String, style: const TextStyle(height: 1.4)),
                  ]),
                ),
              ),
            ]),
          ).animate().fadeIn(delay: (i * 200).ms),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: K.tealDim, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline, color: K.teal),
            const SizedBox(width: 10),
            Expanded(child: Text(c['lesson'] as String, style: const TextStyle(height: 1.42, fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 12),
        Text(c['disclaimer'] as String, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text('${l.caseSources}: ${sources.join('; ')}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => context.pop(), child: Text(l.back)),
      ]),
      if (stopped) const Positioned.fill(child: Confetti()),
    ]);
  }
}
