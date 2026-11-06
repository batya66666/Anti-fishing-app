import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/confetti.dart';
import '../../effects/mascot.dart';

class ShiftSummary {
  ShiftSummary({required this.scenarios, required this.results, required this.levelBefore, required this.levelAfter});
  final List<Scenario> scenarios;
  final Map<String, Evaluation> results;
  final int levelBefore;
  final int levelAfter;
}

/// End of shift. The limit is part of the story: your shift is over, not your free tier.
class ShiftReportScreen extends ConsumerStatefulWidget {
  const ShiftReportScreen({super.key, required this.summary});
  final ShiftSummary? summary;

  @override
  ConsumerState<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends ConsumerState<ShiftReportScreen> {
  @override
  void initState() {
    super.initState();
    final s = widget.summary;
    if (s != null) {
      if (s.levelAfter > s.levelBefore) {
        Sfx.play('levelup');
      } else {
        Sfx.success();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final summary = widget.summary;
    if (summary == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const Scaffold();
    }
    final me = ref.watch(appProvider).me;
    final results = summary.results;
    final total = results.length;
    final good = results.values.where((e) => e.correct).length;
    final reported = results.values.where((e) => e.reported).length;
    final attacks = results.values.where((e) => e.attack).length;
    final hacked = results.values.where((e) => e.hacked).length;
    final xp = results.values.fold<int>(0, (a, e) => a + e.xp) + 30;
    final levelUp = summary.levelAfter > summary.levelBefore;
    final misses = summary.scenarios.where((s) => results[s.id] != null && !results[s.id]!.correct).toList();
    final great = total > 0 && good * 4 >= total * 3;

    return Scaffold(
      body: Stack(children: [
        SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: Mascot(mood: great ? MascotMood.cheering : (hacked > 0 ? MascotMood.worried : MascotMood.happy), size: 130)),
            Text(l.reportTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(l.reportProtected(good, total), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, color: K.teal, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (levelUp && me != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF5B4BE0), Color(0xFF0F4D47)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.workspace_premium, size: 34, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.promotion(me.title), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                ]),
              ).animate().scale(duration: 420.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
            ],
            Row(children: [
              Expanded(child: _Stat(value: '+$xp', label: 'XP', color: K.warn, icon: Icons.bolt)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(value: '${me?.streak ?? 0}', label: l.streak, color: K.warn, icon: Icons.local_fire_department)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(value: '$reported/$attacks', label: l.reportedShort, color: K.teal, icon: Icons.flag)),
            ]),
            if (misses.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(l.reportMissed, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final s in misses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: K.line)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(results[s.id]!.explanation, style: const TextStyle(color: K.muted, fontSize: 13.5, height: 1.35)),
                    ]),
                  ),
                ),
              Text(l.reportWillReturn, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: K.surface2, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.nightlight_round, color: K.violet),
                const SizedBox(width: 10),
                Expanded(child: Text(l.reportRest, style: const TextStyle(height: 1.35))),
              ]),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
          ]),
        ),
        if (great || levelUp) const Positioned.fill(child: Confetti(count: 140)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color, required this.icon});
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: K.line)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 20)),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 12)),
      ]),
    );
  }
}
