import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/difficulty.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/mascot.dart';
import 'scenario_player.dart';

/// Question after question, for as long as you like. New ones first; after that, what you saw longest ago.
class EndlessScreen extends ConsumerStatefulWidget {
  const EndlessScreen({super.key});

  @override
  ConsumerState<EndlessScreen> createState() => _EndlessScreenState();
}

class _EndlessScreenState extends ConsumerState<EndlessScreen> {
  String? _level;
  bool _started = false;
  final List<Scenario> _queue = [];
  bool _loading = false;
  Object? _error;
  int _answered = 0;
  int _correct = 0;
  int _streak = 0;
  int _best = 0;
  int _key = 0;

  Future<void> _start() async {
    Sfx.click();
    setState(() {
      _started = true;
      _queue.clear();
      _answered = 0;
      _correct = 0;
      _streak = 0;
      _best = 0;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await ref.read(repoProvider).endless(difficulty: _level);
      if (!mounted) return;
      setState(() {
        _queue.addAll(next);
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  void _advance() {
    setState(() {
      _queue.removeAt(0);
      _key++;
    });
    if (_queue.length <= 2 && !_loading) _load();
    ref.read(appProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final forced = ref.watch(appProvider.select((s) => s.me?.forcedDifficulty));
    if (!_started) return _picker(context, forced);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.endlessTitle),
        leading: IconButton(icon: const Icon(Icons.close), tooltip: l.close, onPressed: () => context.pop()),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 6), child: Center(child: Pill(icon: Icons.local_fire_department, label: '$_streak', color: K.warn))),
          Padding(padding: const EdgeInsets.only(right: 14), child: Center(child: Pill(icon: Icons.check_circle_outline, label: '$_correct/$_answered', color: K.teal))),
        ],
      ),
      body: _queue.isEmpty
          ? (_error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(l.errorGeneric), const SizedBox(height: 12), OutlinedButton(onPressed: _load, child: Text(l.retry))]))
              : const Center(child: CircularProgressIndicator()))
          : ScenarioPlayer(
              key: ValueKey('${_queue.first.id}-$_key'),
              scenario: _queue.first,
              simple: ref.read(appProvider).simple,
              submit: (action, ms) async {
                final e = await ref.read(repoProvider).practice(scenarioId: _queue.first.id, context: 'endless', action: action, ms: ms);
                setState(() {
                  _answered++;
                  if (e.correct) {
                    _correct++;
                    _streak++;
                    if (_streak > _best) _best = _streak;
                  } else {
                    _streak = 0;
                  }
                });
                return e;
              },
              onNext: _advance,
              nextLabel: l.endlessNext,
            ),
    );
  }

  Widget _picker(BuildContext context, String? forced) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.endlessTitle)),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const Center(child: Mascot(mood: MascotMood.cheering, size: 120)),
          const SizedBox(height: 6),
          Text(l.endlessIntro, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 15.5, height: 1.4)),
          const SizedBox(height: 18),
          Text(l.difficultyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (forced != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: K.warn.withValues(alpha: 0.5))),
              child: Row(children: [
                Icon(difficultyIcon(forced), color: difficultyColor(forced)),
                const SizedBox(width: 10),
                Expanded(child: Text(l.difficultyForced(difficultyName(l, forced)), style: const TextStyle(height: 1.35))),
              ]),
            )
          else ...[
            _LevelTile(value: null, group: _level, title: l.difficultyMix, body: l.difficultyMixBody, onTap: (v) => setState(() => _level = v)),
            for (final d in difficulties) _LevelTile(value: d, group: _level, title: difficultyName(l, d), body: difficultyBody(l, d), onTap: (v) => setState(() => _level = v)),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: _start, icon: const Icon(Icons.all_inclusive), label: Text(l.endlessStart)),
        ]),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.value, required this.group, required this.title, required this.body, required this.onTap});
  final String? value;
  final String? group;
  final String title;
  final String body;
  final ValueChanged<String?> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    final color = value == null ? K.teal : difficultyColor(value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? K.tealDim : K.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Sfx.click();
            onTap(value);
          },
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? K.teal : K.line, width: selected ? 2 : 1)),
            child: Row(children: [
              Icon(value == null ? Icons.shuffle : difficultyIcon(value!), color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(body, style: const TextStyle(color: K.muted, fontSize: 13, height: 1.3)),
                ]),
              ),
              if (selected) const Icon(Icons.check_circle, color: K.teal, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}
