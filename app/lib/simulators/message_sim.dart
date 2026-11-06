import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// SMS thread or messenger chat.
class MessageSim extends StatelessWidget {
  const MessageSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final chat = s.type == 'chat';
    final links = s.list('links');
    final tint = chat ? const Color(0xFFE7F3E9) : K.simBg2;
    final header = chat ? const Color(0xFF1F6F5C) : K.simBg;
    final headerInk = chat ? Colors.white : K.simInk;
    final phrases = props.bodyPhrases;

    return ColoredBox(
      color: tint,
      child: Column(children: [
        Container(
          color: header,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: chat ? Colors.white24 : const Color(0xFFDCE6F2),
              child: Icon(Icons.person, color: chat ? Colors.white : const Color(0xFF29527A), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FlagHighlight(active: props.isFlagged('sender'), radius: 6, child: Text(s.str('sender'), style: TextStyle(color: headerInk, fontWeight: FontWeight.w700, fontSize: 15))),
                const SizedBox(height: 2),
                FlagHighlight(
                  active: props.isFlagged('number'),
                  radius: 6,
                  child: Text(s.str('number'), style: TextStyle(fontFamily: K.mono, color: chat ? Colors.white70 : K.simMuted, fontSize: 12)),
                ),
              ]),
            ),
            Text(chat ? 'Chat' : 'SMS', style: TextStyle(color: chat ? Colors.white70 : K.simMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(14), children: [
            for (final m in s.list('messages'))
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text.rich(richBody(m['text'] as String, const TextStyle(fontSize: 15.5, color: K.simInk, height: 1.38), phrases)),
                      const SizedBox(height: 4),
                      Text((m['time'] as String?) ?? '', style: const TextStyle(fontSize: 11, color: K.simMuted)),
                    ]),
                  ),
                ),
              ),
            for (final (i, link) in links.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FlagHighlight(
                    active: props.isFlagged('link:$i'),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: props.onAction == null ? () => showLinkPeek(context, link['href'] as String) : () => props.onAction!('click_link'),
                        onLongPress: () => showLinkPeek(context, link['href'] as String, onOpen: props.onAction == null ? null : () => props.onAction!('click_link')),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.link, size: 18, color: K.simLink),
                            const SizedBox(width: 6),
                            Flexible(child: Text(link['text'] as String, style: const TextStyle(color: K.simLink, fontSize: 14, decoration: TextDecoration.underline, decorationColor: K.simLink))),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        ActionBar(
          onAction: props.onAction,
          actions: [
            SimAction('open', l.actOk, Icons.check),
            SimAction('reply', l.actReply, Icons.reply),
            SimAction('delete', l.actDelete, Icons.delete_outline),
            SimAction('report', l.actReport, Icons.flag, primary: true),
          ],
        ),
      ]),
    );
  }
}
