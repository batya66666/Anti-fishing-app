import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// A realistic mail client of our own design: light, plain, and nothing like the game around it.
class MailSim extends StatefulWidget {
  const MailSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  State<MailSim> createState() => _MailSimState();
}

class _MailSimState extends State<MailSim> {
  bool _showAddress = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = widget.s;
    final p = widget.props;
    final links = s.list('links');
    final attachments = s.list('attachments');
    final addressVisible = _showAddress || p.answered || p.picking;
    final name = s.str('from_name');

    return ColoredBox(
      color: K.simBg,
      child: Column(children: [
        Container(
          color: K.simBg2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(children: [
            const Icon(Icons.mail_outline, size: 18, color: K.simMuted),
            const SizedBox(width: 8),
            const Text('OfficeMail', style: TextStyle(color: K.simMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(s.str('time'), style: const TextStyle(color: K.simMuted, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FlagHighlight(
                active: p.isFlagged('subject'),
                child: PickTarget(
                  props: p,
                  target: 'subject',
                  child: Text(s.str('subject'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: K.simInk, height: 1.25)),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: p.answered || p.picking
                    ? null
                    : () {
                        Sfx.click();
                        setState(() => _showAddress = !_showAddress);
                      },
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDCE6F2),
                    child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF29527A), fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: K.simInk, fontSize: 15)),
                      const SizedBox(height: 2),
                      if (addressVisible)
                        FlagHighlight(
                          active: p.isFlagged('from_email'),
                          radius: 6,
                          child: PickTarget(
                            props: p,
                            target: 'from_email',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                              child: Text('<${s.str('from_email')}>', style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, color: K.simInk)),
                            ),
                          ),
                        )
                      else
                        Row(children: [
                          Text(l.simToMe, style: const TextStyle(color: K.simMuted, fontSize: 13)),
                          const Icon(Icons.expand_more, size: 18, color: K.simMuted),
                        ]),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              if (p.picking)
                for (final sentence in sentencesOf(s.str('body_md')))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: PickTarget(
                      props: p,
                      target: 'body:$sentence',
                      child: Text(sentence, style: const TextStyle(fontSize: 15, color: K.simInk, height: 1.4)),
                    ),
                  )
              else
                Text.rich(richBody(s.str('body_md'), const TextStyle(fontSize: 15.5, color: K.simInk, height: 1.45), p.bodyPhrases)),
              for (final (i, link) in links.indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FlagHighlight(
                      active: p.isFlagged('link:$i'),
                      child: PickTarget(props: p, target: 'link:$i', child: _LinkButton(link: link, props: p)),
                    ),
                  ),
                ),
              if (attachments.isNotEmpty) const SizedBox(height: 18),
              for (final (i, a) in attachments.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FlagHighlight(
                    active: p.isFlagged('attachment:$i'),
                    child: PickTarget(props: p, target: 'attachment:$i', child: _Attachment(a: a, props: p)),
                  ),
                ),
            ]),
          ),
        ),
        if (!p.picking)
          ActionBar(
            onAction: p.onAction,
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

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.link, required this.props});
  final Map<String, dynamic> link;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    final href = link['href'] as String;
    final text = Text(link['text'] as String, style: const TextStyle(color: K.simLink, fontWeight: FontWeight.w600, fontSize: 15.5, decoration: TextDecoration.underline, decorationColor: K.simLink));
    if (props.picking) return text;
    return Tooltip(
      message: href,
      triggerMode: TooltipTriggerMode.manual,
      textStyle: const TextStyle(fontFamily: K.mono, fontSize: 12, color: Colors.white),
      child: GestureDetector(
        onTap: props.onAction == null ? () => showLinkPeek(context, href) : () => props.onAction!('click_link'),
        onLongPress: () => showLinkPeek(context, href, onOpen: props.onAction == null ? null : () => props.onAction!('click_link')),
        onSecondaryTap: () => showLinkPeek(context, href, onOpen: props.onAction == null ? null : () => props.onAction!('click_link')),
        child: MouseRegion(cursor: SystemMouseCursors.click, child: Padding(padding: const EdgeInsets.all(4), child: text)),
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({required this.a, required this.props});
  final Map<String, dynamic> a;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    final name = a['name'] as String;
    final kb = (a['size_kb'] as num).toInt();
    return Material(
      color: K.simBg2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: props.onAction == null || props.picking ? null : () => props.onAction!('open_attachment'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            const Icon(Icons.attach_file, color: K.simMuted, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontFamily: K.mono, fontSize: 13, color: K.simInk, fontWeight: FontWeight.w700))),
            Text('$kb KB', style: const TextStyle(color: K.simMuted, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
