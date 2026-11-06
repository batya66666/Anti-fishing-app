import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// What every simulator gets. After the answer [onAction] is null and [reveal] holds the red flags to mark.
class SimProps {
  const SimProps({this.onAction, this.reveal, this.selected, this.onToggle, this.simple = false});

  final void Function(String action)? onAction;
  final List<RedFlag>? reveal;

  /// Spot-the-flags mode: tapped elements, and the callback that toggles one.
  final Set<String>? selected;
  final void Function(String target)? onToggle;
  final bool simple;

  bool get answered => reveal != null;
  bool get picking => onToggle != null;
  bool isFlagged(String target) => reveal?.any((f) => f.target == target) ?? false;

  /// Phrases to mark in running text.
  List<String> get bodyPhrases => (reveal ?? const <RedFlag>[]).where((f) => f.target.startsWith('body:')).map((f) => f.target.substring(5)).toList();
}

/// Pulsing red frame around an element that was a red flag.
class FlagHighlight extends StatefulWidget {
  const FlagHighlight({super.key, required this.active, required this.child, this.radius = 8});
  final bool active;
  final Widget child;
  final double radius;

  @override
  State<FlagHighlight> createState() => _FlagHighlightState();
}

class _FlagHighlightState extends State<FlagHighlight> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didUpdateWidget(FlagHighlight old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void initState() {
    super.initState();
    _sync();
  }

  void _sync() {
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final a = 0.45 + 0.55 * (0.5 + 0.5 * sin(_c.value * 2 * pi));
        return Stack(clipBehavior: Clip.none, children: [
          Container(
            decoration: BoxDecoration(
              color: K.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(color: K.danger.withValues(alpha: a), width: 2),
              boxShadow: [BoxShadow(color: K.danger.withValues(alpha: a * 0.35), blurRadius: 10)],
            ),
            child: child,
          ),
          Positioned(
            top: -8,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: K.danger, shape: BoxShape.circle),
              child: const Icon(Icons.flag, size: 12, color: Colors.white),
            ),
          ),
        ]);
      },
    );
  }
}

/// A tappable piece of a message in spot-the-flags mode.
class PickTarget extends StatelessWidget {
  const PickTarget({super.key, required this.props, required this.target, required this.child});
  final SimProps props;
  final String target;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!props.picking) return child;
    final on = props.selected?.contains(target) ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Sfx.click();
        props.onToggle!(target);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: on ? const Color(0x33FF4D5E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? K.danger : K.simLine),
        ),
        child: child,
      ),
    );
  }
}

class SimAction {
  const SimAction(this.id, this.label, this.icon, {this.primary = false});
  final String id;
  final String label;
  final IconData icon;
  final bool primary;
}

/// Row of reactions at the bottom of a message. "Report" is always the most prominent one.
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.actions, required this.onAction});
  final List<SimAction> actions;
  final void Function(String)? onAction;

  @override
  Widget build(BuildContext context) {
    if (onAction == null) return const SizedBox.shrink();
    return Container(
      color: K.simBg,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(children: [
          for (final a in actions)
            Expanded(
              flex: a.primary ? 2 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: a.primary ? const Color(0xFFD92D3F) : K.simBg2,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onAction!(a.id),
                    child: SizedBox(
                      height: 56,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(a.icon, size: 22, color: a.primary ? Colors.white : K.simInk),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(a.label, maxLines: 1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: a.primary ? Colors.white : K.simInk)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Text with **bold** segments, and red flag phrases marked after the answer.
TextSpan richBody(String source, TextStyle base, List<String> phrases) {
  final spans = <InlineSpan>[];
  final bold = RegExp(r'\*\*(.+?)\*\*');
  var last = 0;
  void addPlain(String text, TextStyle style) {
    if (text.isEmpty) return;
    if (phrases.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
      return;
    }
    final lower = text.toLowerCase();
    var pos = 0;
    while (pos < text.length) {
      var next = -1;
      var length = 0;
      for (final p in phrases) {
        final i = lower.indexOf(p.toLowerCase(), pos);
        if (i >= 0 && (next < 0 || i < next)) {
          next = i;
          length = p.length;
        }
      }
      if (next < 0) {
        spans.add(TextSpan(text: text.substring(pos), style: style));
        return;
      }
      if (next > pos) spans.add(TextSpan(text: text.substring(pos, next), style: style));
      spans.add(TextSpan(
        text: text.substring(next, next + length),
        style: style.copyWith(backgroundColor: const Color(0x40FF4D5E), color: const Color(0xFFB00020), fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: K.danger),
      ));
      pos = next + length;
    }
  }

  for (final m in bold.allMatches(source)) {
    addPlain(source.substring(last, m.start), base);
    addPlain(m.group(1)!, base.copyWith(fontWeight: FontWeight.w700));
    last = m.end;
  }
  addPlain(source.substring(last), base);
  return TextSpan(children: spans, style: base);
}

/// Splits a body into tappable sentences, without markdown markers.
List<String> sentencesOf(String body) {
  final plain = body.replaceAll('**', '');
  return plain
      .split('\n')
      // A sentence ends after a real word: "S. Müller" or "Dr. Lang" stay in one piece.
      .expand((line) => line.split(RegExp(r'(?<=[a-zäöüß0-9"]{2}[.!?:])\s+')))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// "Where does this link really go?" The habit of checking is the point of the exercise.
Future<void> showLinkPeek(BuildContext context, String href, {VoidCallback? onOpen}) {
  final l = context.l;
  final uri = Uri.tryParse(href);
  final host = uri?.host ?? href;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: K.simBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.linkPeekTitle, style: const TextStyle(color: K.simMuted, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SelectableText.rich(_urlSpan(href, host), style: const TextStyle(fontFamily: K.mono, fontSize: 15, color: K.simInk)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: K.simInk, side: const BorderSide(color: K.simLine)),
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.close),
              ),
            ),
            if (onOpen != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: K.simLink, foregroundColor: Colors.white, minimumSize: const Size(48, 48)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onOpen();
                  },
                  child: Text(l.openLink),
                ),
              ),
            ],
          ]),
        ]),
      ),
    ),
  );
}

/// Bolds the part of a URL that actually decides who owns it.
TextSpan _urlSpan(String href, String host) {
  final i = href.indexOf(host);
  if (host.isEmpty || i < 0) return TextSpan(text: href);
  final parts = host.split('.');
  final owner = parts.length >= 2 ? parts.sublist(parts.length - 2).join('.') : host;
  final ownerStart = i + host.length - owner.length;
  return TextSpan(children: [
    TextSpan(text: href.substring(0, ownerStart), style: const TextStyle(color: K.simMuted)),
    TextSpan(text: owner, style: const TextStyle(fontWeight: FontWeight.w700, color: K.simInk, backgroundColor: Color(0x33FFB020))),
    TextSpan(text: href.substring(ownerStart + owner.length), style: const TextStyle(color: K.simMuted)),
  ]);
}

TextSpan urlSpan(String href) => _urlSpan(href, Uri.tryParse(href)?.host ?? '');
