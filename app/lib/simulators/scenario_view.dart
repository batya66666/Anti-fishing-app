import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme.dart';
import '../data/models.dart';
import 'browser_sim.dart';
import 'call_sim.dart';
import 'common.dart';
import 'mail_sim.dart';
import 'message_sim.dart';
import 'misc_sims.dart';

/// Picks the right simulator for a scenario.
class ScenarioView extends StatelessWidget {
  const ScenarioView({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    return switch (s.type) {
      'email' => MailSim(s: s, props: props),
      'sms' || 'chat' => MessageSim(s: s, props: props),
      'url' => BrowserSim(s: s, props: props),
      'call' => CallSim(s: s, props: props),
      'qr' => QrSim(s: s, props: props),
      'push' => PushSim(s: s, props: props),
      'file' => FileSim(s: s, props: props),
      _ => SceneSim(s: s, props: props),
    };
  }
}

IconData channelIcon(String type) => switch (type) {
      'email' => Icons.mail_outline,
      'sms' => Icons.sms_outlined,
      'chat' => Icons.chat_bubble_outline,
      'url' => Icons.language,
      'call' => Icons.call,
      'qr' => Icons.qr_code_2,
      'push' => Icons.notifications_active_outlined,
      'file' => Icons.insert_drive_file_outlined,
      _ => Icons.place_outlined,
    };

/// Compact, read-only card for swipe mode and duels: everything needed for a verdict at one glance.
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({super.key, required this.s});
  final Scenario s;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: K.simBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: K.simBg2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Icon(channelIcon(s.type), size: 18, color: K.simMuted),
            const SizedBox(width: 8),
            Expanded(child: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.simInk, fontWeight: FontWeight.w700, fontSize: 14))),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: _content()),
          ),
        ),
      ]),
    );
  }

  Widget _mono(String text) => Text(text, style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, color: K.simInk, height: 1.35));

  Widget _body(String text) => Text.rich(richBody(text, const TextStyle(fontSize: 14.5, color: K.simInk, height: 1.4), const []));

  Widget _content() {
    const gap = SizedBox(height: 10);
    switch (s.type) {
      case 'email':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _mono(s.str('from_email')),
          gap,
          Text(s.str('subject'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: K.simInk, height: 1.25)),
          gap,
          _body(s.str('body_md')),
          for (final l in s.list('links')) ...[gap, _mono('${l['text']} → ${l['href']}')],
          for (final a in s.list('attachments')) ...[
            gap,
            Row(children: [const Icon(Icons.attach_file, size: 16, color: K.simMuted), const SizedBox(width: 4), Expanded(child: _mono(a['name'] as String))]),
          ],
        ]);
      case 'sms' || 'chat':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _mono(s.str('number')),
          gap,
          for (final m in s.list('messages')) ...[
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: K.simBg2, borderRadius: BorderRadius.circular(12)),
              child: _body(m['text'] as String),
            ),
            const SizedBox(height: 8),
          ],
        ]);
      case 'url':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.str('context'), style: const TextStyle(fontSize: 13.5, color: K.simMuted, height: 1.35)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: K.simBg2, borderRadius: BorderRadius.circular(10)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lock, size: 16, color: Color(0xFF2E7D4F)),
              const SizedBox(width: 6),
              Expanded(child: Text.rich(urlSpan(s.str('url')), style: const TextStyle(fontFamily: K.mono, fontSize: 14, color: K.simInk))),
            ]),
          ),
        ]);
      case 'qr':
        return Column(children: [
          Text(s.str('context'), style: const TextStyle(fontSize: 13.5, color: K.simMuted, height: 1.35)),
          gap,
          QrImageView(data: s.str('url'), size: 110, padding: EdgeInsets.zero),
          gap,
          _mono(s.str('url')),
        ]);
      case 'push':
        final n = (s.content['repeat'] as num?)?.toInt() ?? 1;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.str('context'), style: const TextStyle(fontSize: 13.5, color: K.simMuted, height: 1.35)),
          gap,
          Text(s.str('title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: K.simInk)),
          const SizedBox(height: 4),
          _body(s.str('body')),
          if (n > 1) ...[gap, Text('× $n', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD92D3F), fontSize: 18))],
        ]);
      case 'file':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.str('context'), style: const TextStyle(fontSize: 13.5, color: K.simMuted, height: 1.35)),
          gap,
          Row(children: [
            const Icon(Icons.insert_drive_file_outlined, size: 30, color: Color(0xFF29527A)),
            const SizedBox(width: 8),
            Expanded(child: _mono(s.str('display_name').isNotEmpty ? s.str('display_name') : s.str('name'))),
          ]),
          const SizedBox(height: 6),
          Text('${s.str('shown_type')} · ${(s.content['size_kb'] as num).toInt()} KB', style: const TextStyle(fontSize: 13, color: K.simMuted)),
        ]);
      default:
        return _body(s.snippet);
    }
  }
}
