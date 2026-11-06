import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_state.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/repository.dart';
import '../../effects/mascot.dart';

/// Duel tab: ranked queue, or a friendly match by code and QR.
class DuelLobbyTab extends ConsumerStatefulWidget {
  const DuelLobbyTab({super.key});

  @override
  ConsumerState<DuelLobbyTab> createState() => _DuelLobbyTabState();
}

class _DuelLobbyTabState extends ConsumerState<DuelLobbyTab> {
  StreamSubscription<String>? _found;
  bool _searching = false;
  String? _code;
  bool _busy = false;
  final _joinField = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    final client = ref.read(repoProvider).duelClient();
    _found = client.matchFound.listen((id) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _code = null;
      });
      context.push('/duel/match/$id');
    });
    try {
      await client.connect();
    } catch (_) {
      // Stomp keeps trying in the background; matching simply starts when the connection is back.
    }
  }

  @override
  void dispose() {
    _found?.cancel();
    _joinField.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    Sfx.click();
    setState(() => _searching = true);
    try {
      await ref.read(repoProvider).queueDuel();
    } catch (_) {
      if (mounted) {
        setState(() => _searching = false);
        _snack(context.l.errorGeneric);
      }
    }
  }

  Future<void> _cancel() async {
    setState(() => _searching = false);
    await ref.read(repoProvider).leaveQueue();
  }

  Future<void> _friendly() async {
    Sfx.click();
    setState(() => _busy = true);
    try {
      final code = await ref.read(repoProvider).createFriendly();
      if (mounted) setState(() => _code = code);
    } on DuelJoinFailed {
      if (mounted) _snack(context.l.duelNeedsServer);
    } catch (_) {
      if (mounted) _snack(context.l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bot() async {
    Sfx.click();
    final level = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: K.surface,
      isScrollControlled: true,
      builder: (_) => const _BotPicker(),
    );
    if (level == null || !mounted) return;
    Sfx.click();
    final id = await ref.read(repoProvider).friendlyAgainstBot(level: level == 'auto' ? null : level);
    if (!mounted) return;
    setState(() => _code = null);
    context.push('/duel/match/$id');
  }

  Future<void> _join() async {
    final code = _joinField.text.trim();
    if (code.isEmpty) return;
    Sfx.click();
    try {
      final id = await ref.read(repoProvider).joinFriendly(code);
      if (mounted) context.push('/duel/match/$id');
    } on DuelJoinFailed {
      if (mounted) _snack(context.l.duelBadCode);
    } catch (_) {
      if (mounted) _snack(context.l.errorGeneric);
    }
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final me = ref.watch(appProvider).me;
    if (me == null) return const SizedBox.shrink();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      Text(l.duelTitle, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(l.duelSub, style: const TextStyle(color: K.muted, height: 1.35)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF2B2170), Color(0xFF12334A)]),
        ),
        child: Row(children: [
          Avatars.of(me.avatar, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(me.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(l.duelRecord(me.wins, me.losses), style: const TextStyle(color: K.muted, fontSize: 13)),
            ]),
          ),
          Column(children: [
            Text('${me.elo}', style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 28, color: K.violet)),
            const Text('ELO', style: TextStyle(color: K.muted, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      if (_searching)
        _Searching(onCancel: _cancel)
      else
        FilledButton.icon(onPressed: _search, icon: const Icon(Icons.travel_explore), label: Text(l.duelFind)),
      const SizedBox(height: 18),
      Text(l.duelFriendly, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (_code != null)
        _CodeCard(code: _code!, onBot: _bot, onClose: () => setState(() => _code = null))
      else ...[
        OutlinedButton.icon(onPressed: _busy ? null : _friendly, icon: const Icon(Icons.qr_code_2), label: Text(l.duelCreateCode)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _joinField,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontFamily: K.mono, letterSpacing: 3, fontWeight: FontWeight.w700),
              decoration: InputDecoration(hintText: l.duelCodeHint, isDense: true),
              onSubmitted: (_) => _join(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: _join, child: Text(l.duelJoin)),
        ]),
        const SizedBox(height: 10),
        TextButton.icon(onPressed: _bot, icon: const Icon(Icons.smart_toy_outlined), label: Text(l.duelVsBot)),
      ],
    ]);
  }
}

class _BotPicker extends StatelessWidget {
  const _BotPicker();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final bots = [
      ('auto', l.botAuto, l.botAutoBody, Icons.tune, K.teal),
      ('rookie', l.botRookie, l.botRookieBody, Icons.school_outlined, const Color(0xFFD08A52)),
      ('analyst', l.botAnalyst, l.botAnalystBody, Icons.manage_search, const Color(0xFFB9C6D2)),
      ('veteran', l.botVeteran, l.botVeteranBody, Icons.military_tech_outlined, const Color(0xFFFFD166)),
      ('ciso', l.botCiso, l.botCisoBody, Icons.shield_moon_outlined, K.danger),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.botPickTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(l.botNoElo, style: const TextStyle(color: K.muted, fontSize: 13)),
          const SizedBox(height: 10),
          for (final (id, name, body, icon, color) in bots)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: K.surface2,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context, id),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                          Text(body, style: const TextStyle(color: K.muted, fontSize: 13, height: 1.3)),
                        ]),
                      ),
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

class _Searching extends StatelessWidget {
  const _Searching({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: K.teal.withValues(alpha: 0.5))),
      child: Row(children: [
        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
        const SizedBox(width: 14),
        Expanded(child: Text(l.duelSearching, style: const TextStyle(fontWeight: FontWeight.w600))),
        TextButton(onPressed: onCancel, child: Text(l.cancel)),
      ]),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1500.ms, color: K.teal.withValues(alpha: 0.2));
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.onBot, required this.onClose});
  final String code;
  final VoidCallback onBot;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: K.line)),
      child: Column(children: [
        Text(l.duelScanMe, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: QrImageView(data: Config.duelLink(code), size: 200, padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 10),
        Text(code, style: const TextStyle(fontFamily: K.mono, fontWeight: FontWeight.w700, fontSize: 30, letterSpacing: 6, color: K.teal)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          Text(l.duelWaiting, style: const TextStyle(color: K.muted)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: onClose, child: Text(l.cancel))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(onPressed: onBot, icon: const Icon(Icons.smart_toy_outlined, size: 18), label: Text(l.duelBotShort))),
        ]),
      ]),
    ).animate().fadeIn().scaleXY(begin: 0.96, end: 1);
  }
}

/// Entry point for QR codes: joins a friend's match, or the arena where everybody from the audience gets paired up.
class DuelEntryScreen extends ConsumerStatefulWidget {
  const DuelEntryScreen({super.key, this.code, this.arena = false});
  final String? code;
  final bool arena;

  @override
  ConsumerState<DuelEntryScreen> createState() => _DuelEntryScreenState();
}

class _DuelEntryScreenState extends ConsumerState<DuelEntryScreen> {
  StreamSubscription<String>? _found;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await ref.read(appProvider.notifier).skipOnboarding();
    final repo = ref.read(repoProvider);
    try {
      final client = repo.duelClient();
      _found = client.matchFound.listen((id) {
        if (mounted) context.go('/duel/match/$id');
      });
      await client.connect();
      if (widget.arena) {
        await repo.queueDuel();
      } else {
        final id = await repo.joinFriendly(widget.code!);
        if (mounted) context.go('/duel/match/$id');
      }
    } on DuelJoinFailed {
      if (mounted) setState(() => _error = context.l.duelBadCode);
    } catch (_) {
      if (mounted) setState(() => _error = context.l.errorGeneric);
    }
  }

  @override
  void dispose() {
    _found?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Mascot(mood: _error == null ? MascotMood.happy : MascotMood.worried, size: 140),
            const SizedBox(height: 14),
            Text(_error ?? l.duelSearching, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            if (_error == null)
              const CircularProgressIndicator()
            else ...[
              FilledButton(onPressed: () => context.go('/duel/arena'), child: Text(l.duelFind)),
              const SizedBox(height: 8),
              TextButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
            ],
          ]),
        ),
      ),
    );
  }
}
