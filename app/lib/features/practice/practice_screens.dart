import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';
import '../play/scenario_player.dart';

/// Spaced repetition. Always free: nobody should have to pay to fix their mistakes.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repoProvider);
    return ScenarioRun(
      title: context.l.reviewTitle,
      context: 'review',
      load: repo.reviewDue,
      submit: (id, action, ms) => repo.practice(scenarioId: id, context: 'review', action: action, ms: ms),
      onFinished: () => ref.read(appProvider.notifier).refresh(),
    );
  }
}

class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.module});
  final int module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repoProvider);
    final l = context.l;
    final me = ref.read(appProvider).me;
    final solved = me?.moduleProgress[module] ?? 0;
    return ScenarioRun(
      title: moduleName(l, module),
      context: 'module',
      load: () => repo.moduleLesson(module),
      solvedBefore: me?.moduleProgress[module] ?? 0,
      total: me?.moduleTotals[module],
      submit: (id, action, ms) => repo.practice(scenarioId: id, context: 'module', action: action, ms: ms),
      onFinished: () => ref.read(appProvider.notifier).refresh(),
      // Coming back to a lesson goes straight to the next question.
      intro: solved > 0
          ? null
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: K.tealDim, shape: BoxShape.circle, border: Border.all(color: K.teal, width: 2)),
                child: Icon(moduleIcon(module), color: K.teal, size: 36),
              ),
              const SizedBox(height: 16),
              Text(moduleName(l, module), style: Theme.of(context).textTheme.headlineSmall),
            ]),
      theory: moduleTip(l, module),
    );
  }
}
