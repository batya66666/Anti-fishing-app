import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../effects/mascot.dart';

/// Three short screens, then language and mode. No account needed: privacy by default.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;
  String _mode = 'standard';

  void _next() {
    Sfx.click();
    setState(() => _page++);
  }

  Future<void> _finish() async {
    Sfx.success();
    final locale = ref.read(appProvider).locale;
    await ref.read(appProvider.notifier).finishOnboarding(locale: locale, mode: _mode);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pages = [
      _Pitch(mood: MascotMood.happy, title: l.onbTitle1, body: l.onbBody1),
      _Pitch(mood: MascotMood.hooked, title: l.onbTitle2, body: l.onbBody2),
      _Pitch(mood: MascotMood.cheering, title: l.onbTitle3, body: l.onbBody3),
      _setup(context),
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < pages.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i <= _page ? K.teal : K.surface2, borderRadius: BorderRadius.circular(99)),
                ),
            ]),
            Expanded(child: KeyedSubtree(key: ValueKey(_page), child: pages[_page].animate().fadeIn(duration: 260.ms).slideX(begin: 0.05, end: 0))),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _page < pages.length - 1 ? _next : _finish,
                child: Text(_page < pages.length - 1 ? l.next : l.onbStart),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _setup(BuildContext context) {
    final l = context.l;
    final locale = ref.watch(appProvider.select((s) => s.locale));
    return Center(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.onbLanguage, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'de', label: Text('Deutsch')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {locale},
            onSelectionChanged: (s) => ref.read(appProvider.notifier).updateSettings(locale: s.first),
          ),
          const SizedBox(height: 26),
          Text(l.onbMode, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _ModeCard(selected: _mode == 'standard', icon: Icons.business_center_outlined, title: l.modeOffice, body: l.modeOfficeBody, onTap: () => setState(() => _mode = 'standard')),
          const SizedBox(height: 10),
          _ModeCard(selected: _mode == 'simple', icon: Icons.favorite_border, title: l.modeSimple, body: l.modeSimpleBody, onTap: () => setState(() => _mode = 'simple')),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lock_outline, size: 16, color: K.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(l.onbPrivacy, style: Theme.of(context).textTheme.bodySmall)),
          ]),
        ]),
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({required this.mood, required this.title, required this.body});
  final MascotMood mood;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Mascot(mood: mood, size: 190),
      const SizedBox(height: 22),
      Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 12),
      Text(body, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16.5, height: 1.45)),
    ]);
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.selected, required this.icon, required this.title, required this.body, required this.onTap});
  final bool selected;
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? K.tealDim : K.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? K.teal : K.line, width: selected ? 2 : 1)),
          child: Row(children: [
            Icon(icon, color: selected ? K.teal : K.muted, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: K.muted, fontSize: 13.5, height: 1.35)),
              ]),
            ),
            if (selected) const Icon(Icons.check_circle, color: K.teal),
          ]),
        ),
      ),
    );
  }
}
