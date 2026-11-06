import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../effects/mascot.dart';
import 'auth_form.dart';

/// Language first, before anything else is said. Then account or guest, three short screens, and the mode.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _language = 0;
  static const _account = 1;
  static const _firstPitch = 2;
  static const _setup = 5;

  int _page = _language;
  String _mode = 'standard';

  void _next() {
    Sfx.click();
    setState(() => _page++);
  }

  Future<void> _chooseLanguage(String locale) async {
    Sfx.click();
    await ref.read(appProvider.notifier).setLocale(locale);
    if (mounted) setState(() => _page = _account);
  }

  Future<void> _signedIn(bool existing) async {
    // Somebody coming back knows the game, and has already made these choices.
    if (existing) {
      await ref.read(appProvider.notifier).finishOnboarding(locale: ref.read(appProvider).locale);
      if (mounted) context.go('/');
    } else {
      setState(() => _page = _firstPitch);
    }
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
    final Widget page = switch (_page) {
      _language => _LanguagePage(onPick: _chooseLanguage),
      _account => AuthForm(onSignedIn: _signedIn, onGuest: () => setState(() => _page = _firstPitch)),
      2 => _Pitch(mood: MascotMood.happy, title: l.onbTitle1, body: l.onbBody1),
      3 => _Pitch(mood: MascotMood.hooked, title: l.onbTitle2, body: l.onbBody2),
      4 => _Pitch(mood: MascotMood.cheering, title: l.onbTitle3, body: l.onbBody3),
      _ => _setupPage(context),
    };
    final showButton = _page >= _firstPitch;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i <= _setup; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i <= _page ? K.teal : K.surface2, borderRadius: BorderRadius.circular(99)),
                ),
            ]),
            Expanded(child: KeyedSubtree(key: ValueKey(_page), child: page.animate().fadeIn(duration: 260.ms).slideX(begin: 0.05, end: 0))),
            if (showButton)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _page < _setup ? _next : _finish,
                  child: Text(_page < _setup ? l.next : l.onbStart),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _setupPage(BuildContext context) {
    final l = context.l;
    return Center(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.onbMode, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _ModeCard(selected: _mode == 'standard', icon: Icons.business_center_outlined, title: l.modeOffice, body: l.modeOfficeBody, onTap: () => setState(() => _mode = 'standard')),
          const SizedBox(height: 10),
          _ModeCard(selected: _mode == 'simple', icon: Icons.favorite_border, title: l.modeSimple, body: l.modeSimpleBody, onTap: () => setState(() => _mode = 'simple')),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: () => context.push('/theory'), icon: const Icon(Icons.menu_book_outlined, size: 18), label: Text(l.theoryOptional)),
          ),
          const SizedBox(height: 6),
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

/// Says everything in both languages: this is the one screen where we do not know yet what you read.
class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Center(child: Mascot(mood: MascotMood.cheering, size: 150)),
          const SizedBox(height: 10),
          const Text('Willkommen! Welcome!', textAlign: TextAlign.center, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 28)),
          const SizedBox(height: 6),
          const Text('Wähle deine Sprache\nChoose your language', textAlign: TextAlign.center, style: TextStyle(color: K.muted, fontSize: 16, height: 1.4)),
          const SizedBox(height: 22),
          _LanguageButton(code: 'DE', label: 'Deutsch', onTap: () => onPick('de')),
          const SizedBox(height: 10),
          _LanguageButton(code: 'EN', label: 'English', onTap: () => onPick('en')),
        ]),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.code, required this.label, required this.onTap});
  final String code;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: K.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: K.line)),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: K.tealDim, borderRadius: BorderRadius.circular(12)),
              child: Text(code, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, color: K.teal)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
            const Icon(Icons.chevron_right, color: K.muted),
          ]),
        ),
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
