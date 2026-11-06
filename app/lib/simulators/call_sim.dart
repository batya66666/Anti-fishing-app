import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// Full-screen incoming call. The caller speaks through text-to-speech; the player answers from a dialogue tree.
class CallSim extends StatefulWidget {
  const CallSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  State<CallSim> createState() => _CallSimState();
}

class _CallSimState extends State<CallSim> {
  final FlutterTts _tts = FlutterTts();
  bool _accepted = false;
  String? _node;
  Timer? _vibrate;
  Timer? _clock;
  int _seconds = 0;
  bool _ttsWorks = true;

  @override
  void initState() {
    super.initState();
    _node = widget.s.str('start');
    if (widget.props.onAction != null) {
      Sfx.loop('ring');
      _vibrate = Timer.periodic(const Duration(milliseconds: 900), (_) => HapticFeedback.heavyImpact());
    } else {
      _accepted = true;
    }
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setLanguage(widget.s.locale == 'en' ? 'en-GB' : 'de-DE');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(0.92);
    } catch (_) {
      _ttsWorks = false;
    }
  }

  void _say(String text) {
    if (!_ttsWorks || !Sfx.enabled) return;
    try {
      _tts.stop();
      _tts.speak(text);
    } catch (_) {
      // The subtitles carry the call on their own.
    }
  }

  void _stopRinging() {
    _vibrate?.cancel();
    Sfx.stopLoop();
  }

  @override
  void didUpdateWidget(CallSim old) {
    super.didUpdateWidget(old);
    if (widget.props.answered) {
      _tts.stop();
      _clock?.cancel();
    }
  }

  @override
  void dispose() {
    _stopRinging();
    _clock?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _accept() {
    _stopRinging();
    HapticFeedback.mediumImpact();
    setState(() => _accepted = true);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
    _say(_current['say'] as String);
  }

  Map<String, dynamic> get _current => Map<String, dynamic>.from((widget.s.content['nodes'] as Map)[_node] as Map);

  void _choose(Map<String, dynamic> option) {
    Sfx.click();
    final next = option['next'] as String?;
    if (next != null) {
      setState(() => _node = next);
      _say(_current['say'] as String);
    } else {
      _tts.stop();
      widget.props.onAction?.call(option['action'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF12324A), Color(0xFF0A1622)])),
      child: SafeArea(child: _accepted ? _inCall(context) : _ringing(context)),
    );
  }

  Widget _caller({double size = 110}) {
    return Column(children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
        child: Icon(Icons.person, size: size * 0.6, color: Colors.white),
      ),
      const SizedBox(height: 14),
      Text(widget.s.str('caller'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 28, color: Colors.white)),
      const SizedBox(height: 4),
      FlagHighlight(
        active: widget.props.isFlagged('number'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(widget.s.str('number'), style: const TextStyle(fontFamily: K.mono, color: Colors.white70, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _ringing(BuildContext context) {
    final l = context.l;
    return Column(children: [
      const SizedBox(height: 30),
      Text(l.callIncoming, style: const TextStyle(color: Colors.white70, fontSize: 15)),
      const SizedBox(height: 26),
      Stack(alignment: Alignment.center, children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: K.teal.withValues(alpha: 0.5), width: 2)),
          ).animate(onPlay: (c) => c.repeat(), delay: (i * 500).ms).scaleXY(begin: 1, end: 2.2, duration: 1500.ms, curve: Curves.easeOut).fadeOut(duration: 1500.ms),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
          child: const Icon(Icons.person, size: 66, color: Colors.white),
        ),
      ]),
      const SizedBox(height: 34),
      Text(widget.s.str('caller'), textAlign: TextAlign.center, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 30, color: Colors.white)),
      const SizedBox(height: 4),
      Text(widget.s.str('number'), style: const TextStyle(fontFamily: K.mono, color: Colors.white70, fontSize: 15)),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 34),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _RoundButton(
            color: K.danger,
            icon: Icons.call_end,
            label: l.callDecline,
            onTap: () {
              _stopRinging();
              widget.props.onAction?.call('hang_up');
            },
          ),
          _RoundButton(color: const Color(0xFF28C76F), icon: Icons.call, label: l.callAccept, onTap: _accept, pulse: true),
        ]),
      ),
    ]);
  }

  Widget _inCall(BuildContext context) {
    final l = context.l;
    final node = _current;
    final options = ((node['options'] as List?) ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final clock = '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
    return Column(children: [
      const SizedBox(height: 12),
      _caller(size: 74),
      const SizedBox(height: 2),
      Text(clock, style: const TextStyle(fontFamily: K.mono, color: Colors.white60, fontSize: 13)),
      const SizedBox(height: 10),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              key: ValueKey(_node),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkWell(
                  onTap: () => _say(node['say'] as String),
                  child: const Padding(padding: EdgeInsets.only(right: 8, top: 1), child: Icon(Icons.volume_up, color: K.teal, size: 20)),
                ),
                Expanded(child: Text(node['say'] as String, style: const TextStyle(color: Colors.white, fontSize: 15.5, height: 1.4))),
              ]),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 12),
            if (widget.props.onAction != null) ...[
              Text(l.callYourAnswer, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 8),
              for (final (i, o) in options.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => _choose(o),
                    child: Text(o['label'] as String, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                  ).animate().fadeIn(delay: (120 * i + 200).ms),
                ),
            ],
          ]),
        ),
      ),
    ]);
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.color, required this.icon, required this.label, required this.onTap, this.pulse = false});
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 34),
    );
    if (pulse) {
      button = button.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.1, duration: 550.ms, curve: Curves.easeInOut);
    }
    // The whole group is the target, label included: nobody should miss the button when the phone rings.
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          button,
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
