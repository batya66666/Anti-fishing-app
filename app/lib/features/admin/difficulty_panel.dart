import 'package:flutter/material.dart';

import '../../core/difficulty.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../simulators/common.dart';
import '../../simulators/scenario_view.dart';
import 'admin_api.dart';

/// For demonstrating and for checking: pin one level for the whole company, and read every scenario with its solution.
class DifficultyPanel extends StatefulWidget {
  const DifficultyPanel({super.key, required this.api});
  final AdminApi api;

  @override
  State<DifficultyPanel> createState() => _DifficultyPanelState();
}

class _DifficultyPanelState extends State<DifficultyPanel> {
  String? _forced;
  bool _busy = false;
  List<Map<String, dynamic>>? _catalog;
  String? _filter;
  bool _pdfOnly = false;
  String? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale != _locale) {
      _locale = locale;
      _load();
    }
  }

  Future<void> _load() async {
    final forced = await widget.api.forcedDifficulty();
    final catalog = await widget.api.catalog(_locale!);
    if (mounted) {
      setState(() {
        _forced = forced;
        _catalog = catalog;
      });
    }
  }

  Future<void> _set(String? level) async {
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await widget.api.setForcedDifficulty(level);
      setState(() => _forced = level);
      messenger.showSnackBar(SnackBar(content: Text(l.adminDifficultySaved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static bool _hasPdf(Map<String, dynamic> s) => ((s['content'] as Map)['attachments'] as List?)?.any((a) => '${(a as Map)['name']}'.toLowerCase().endsWith('.pdf')) ?? false;

  /// The same rule the server plays by: Diamond also takes genuine Gold messages.
  static bool _fits(Map<String, dynamic> s, String level) => s['difficulty'] == level || (s['is_attack'] != true && level == 'diamond' && s['difficulty'] == 'gold');

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final catalog = _catalog;
    final shown = catalog?.where((s) => (_filter == null || _fits(s, _filter!)) && (!_pdfOnly || _hasPdf(s))).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
      Narrow(
        maxWidth: 860,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.adminDifficultyTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l.adminDifficultyIntro, style: const TextStyle(color: K.muted, height: 1.4)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _LevelButton(label: l.adminDifficultyOff, icon: Icons.tune, color: K.teal, selected: _forced == null, onTap: _busy ? null : () => _set(null)),
            for (final d in difficulties)
              _LevelButton(
                label: '${difficultyName(l, d)} (${catalog?.where((s) => _fits(s, d)).length ?? '–'})',
                icon: difficultyIcon(d),
                color: difficultyColor(d),
                selected: _forced == d,
                onTap: _busy ? null : () => _set(d),
              ),
          ]),
          const SizedBox(height: 8),
          Text(_forced == null ? l.adminDifficultyOffBody : difficultyBody(l, _forced!), style: const TextStyle(color: K.muted, fontSize: 13.5)),
          const SizedBox(height: 22),
          Text(l.adminCatalogTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          if (shown != null) Text(l.adminCatalogSub(shown.length), style: const TextStyle(color: K.muted, fontSize: 13.5)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            ChoiceChip(label: Text(l.adminCatalogAll), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
            for (final d in difficulties) ChoiceChip(label: Text(difficultyName(l, d)), selected: _filter == d, onSelected: (_) => setState(() => _filter = d)),
            FilterChip(label: Text(l.adminCatalogPdfOnly), selected: _pdfOnly, onSelected: (v) => setState(() => _pdfOnly = v)),
          ]),
          const SizedBox(height: 10),
          if (shown == null)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            for (final s in shown) _ScenarioRow(raw: s),
        ]),
      ),
    ]);
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({required this.label, required this.icon, required this.color, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? K.tealDim : K.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? K.teal : K.line, width: selected ? 2 : 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (selected) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: K.teal, size: 17)),
          ]),
        ),
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({required this.raw});
  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = Scenario.fromJson(raw);
    final attack = raw['is_attack'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: K.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _open(context, s),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: K.line)),
            child: Row(children: [
              Icon(channelIcon(s.type), color: K.muted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(s.type == 'call' ? l.inboxCall : s.snippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 12.5)),
                ]),
              ),
              const SizedBox(width: 8),
              Pill(icon: difficultyIcon(s.difficulty), label: difficultyName(l, s.difficulty), color: difficultyColor(s.difficulty)),
              const SizedBox(width: 6),
              Pill(icon: attack ? Icons.phishing : Icons.verified_outlined, label: attack ? l.genAttack : l.genGenuine, color: attack ? K.danger : K.teal),
            ]),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Scenario s) {
    final l = context.l;
    final flags = ((raw['red_flags'] as List?) ?? const []).map((e) => RedFlag.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 460,
          height: 760,
          child: Column(children: [
            Expanded(child: ScenarioView(s: s, props: SimProps(reveal: flags))),
            Container(
              color: K.surface,
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(raw['explanation'] as String, style: const TextStyle(height: 1.4, fontSize: 14)),
                  for (final f in flags)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.flag, size: 14, color: K.danger)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(f.hint, style: const TextStyle(color: K.muted, fontSize: 13, height: 1.35))),
                      ]),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
