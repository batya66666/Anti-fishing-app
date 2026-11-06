import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// A mobile browser with a real address bar. Reading the bar is the whole lesson.
class BrowserSim extends StatelessWidget {
  const BrowserSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final url = s.str('url');
    final brand = s.str('brand');
    return ColoredBox(
      color: K.simBg,
      child: Column(children: [
        _ContextBanner(text: s.str('context')),
        Container(
          color: K.simBg2,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(children: [
            FlagHighlight(
              active: props.isFlagged('secure'),
              radius: 12,
              child: const Padding(padding: EdgeInsets.all(3), child: Icon(Icons.lock, size: 17, color: Color(0xFF2E7D4F))),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: FlagHighlight(
                active: props.isFlagged('url'),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => showLinkPeek(context, url),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text.rich(urlSpan(url), style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, color: K.simInk)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.more_vert, size: 20, color: K.simMuted),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: const Color(0xFF29527A), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(brand.isEmpty ? '?' : brand[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(brand, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: K.simInk))),
              ]),
              const SizedBox(height: 20),
              Text(l.simLoginTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: K.simInk)),
              const SizedBox(height: 12),
              _FakeField(label: l.simUser),
              const SizedBox(height: 10),
              _FakeField(label: l.simPassword, obscure: true),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF29527A), foregroundColor: Colors.white),
                onPressed: props.onAction == null ? null : () => props.onAction!('enter_credentials'),
                child: Text(l.simSignIn),
              ),
            ]),
          ),
        ),
        ActionBar(
          onAction: props.onAction,
          actions: [
            SimAction('leave', l.actLeave, Icons.logout),
            SimAction('report', l.actReport, Icons.flag, primary: true),
          ],
        ),
      ]),
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: K.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 16, color: K.teal),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: K.ink, fontSize: 13.5, height: 1.35))),
      ]),
    );
  }
}

class _FakeField extends StatelessWidget {
  const _FakeField({required this.label, this.obscure = false});
  final String label;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(border: Border.all(color: K.simLine), borderRadius: BorderRadius.circular(8)),
      child: Text(obscure ? '$label  ••••••••' : label, style: const TextStyle(color: K.simMuted, fontSize: 14)),
    );
  }
}

/// Exposed for other simulators that need the same framing.
class ContextBanner extends StatelessWidget {
  const ContextBanner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => _ContextBanner(text: text);
}
