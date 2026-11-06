import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/mascot.dart';

/// "Is this message dangerous?" A daily reason to keep the app. Nothing that goes in here is stored.
class CheckScreen extends ConsumerStatefulWidget {
  const CheckScreen({super.key});

  @override
  ConsumerState<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends ConsumerState<CheckScreen> {
  final _text = TextEditingController();
  CheckResult? _result;
  bool _busy = false;
  String? _imageBase64;
  String? _mediaType;
  String? _imageName;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBase64 = base64Encode(bytes);
      _mediaType = file.mimeType ?? (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
      _imageName = file.name;
    });
  }

  Future<void> _check() async {
    final text = _text.text.trim();
    if (text.isEmpty && _imageBase64 == null) return;
    Sfx.click();
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final r = await ref.read(repoProvider).checkMessage(text: text.isEmpty ? null : text, imageBase64: _imageBase64, mediaType: _mediaType);
      if (!mounted) return;
      r.verdict == 'dangerous' ? Sfx.error() : Sfx.play('notify');
      setState(() => _result = r);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l.errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l.checkTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        Text(l.checkIntro, style: const TextStyle(color: K.muted, height: 1.4)),
        const SizedBox(height: 12),
        TextField(
          controller: _text,
          minLines: 5,
          maxLines: 9,
          maxLength: 8000,
          decoration: InputDecoration(hintText: l.checkHint),
        ),
        const SizedBox(height: 4),
        Wrap(spacing: 7, runSpacing: 7, children: [
          ActionChip(avatar: const Icon(Icons.image_outlined, size: 17), label: Text(_imageName ?? l.checkScreenshot), onPressed: _pick),
          ActionChip(label: Text(l.checkSample1), onPressed: () => setState(() => _text.text = l.checkSample1Text)),
          ActionChip(label: Text(l.checkSample2), onPressed: () => setState(() => _text.text = l.checkSample2Text)),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _check,
          icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.policy_outlined),
          label: Text(l.checkButton),
        ),
        if (r != null) ...[
          const SizedBox(height: 16),
          _ResultCard(r: r).animate().fadeIn().slideY(begin: 0.06, end: 0),
        ],
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_outline, size: 15, color: K.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(l.checkDisclaimer, style: Theme.of(context).textTheme.bodySmall)),
        ]),
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.r});
  final CheckResult r;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (title, color, mood) = switch (r.verdict) {
      'dangerous' => (l.checkDangerous, K.danger, MascotMood.hooked),
      'suspicious' => (l.checkSuspicious, K.warn, MascotMood.worried),
      _ => (l.checkUnclear, K.blue, MascotMood.neutral),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: color, width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Mascot(mood: mood, size: 60),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 21, color: color)),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(value: r.riskScore / 100, minHeight: 7, backgroundColor: K.surface2, color: color),
              ),
              const SizedBox(height: 3),
              Text(l.checkRisk(r.riskScore), style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        for (final f in r.findings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.flag, size: 15, color: color)),
              const SizedBox(width: 7),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(f.detail, style: const TextStyle(color: K.muted, fontSize: 13.5, height: 1.35)),
                ]),
              ),
            ]),
          ),
        const Divider(),
        Text(r.recommendation, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 8),
        Text(r.source == 'ai' ? l.checkSourceAi : l.checkSourceRules, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
