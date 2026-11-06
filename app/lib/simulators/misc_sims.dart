import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'browser_sim.dart';
import 'common.dart';

/// Quishing: you see the code first, and the destination only after scanning.
class QrSim extends StatefulWidget {
  const QrSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  State<QrSim> createState() => _QrSimState();
}

class _QrSimState extends State<QrSim> {
  bool _scanned = false;
  bool _scanning = false;

  void _scan() {
    Sfx.click();
    setState(() => _scanning = true);
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      Sfx.play('notify');
      setState(() {
        _scanning = false;
        _scanned = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = widget.s;
    final p = widget.props;
    final show = _scanned || p.answered;
    final sticker = s.content['sticker'] == true;
    return ColoredBox(
      color: K.simBg,
      child: Column(children: [
        ContextBanner(text: s.str('context')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(s.str('place'), style: const TextStyle(fontWeight: FontWeight.w700, color: K.simInk, fontSize: 16)),
              const SizedBox(height: 12),
              FlagHighlight(
                active: p.isFlagged('note:sticker') || p.isFlagged('note:qr-in-mail'),
                child: Transform.rotate(
                  angle: sticker ? -0.03 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sticker ? const Color(0xFFFFF7D6) : Colors.white,
                      border: Border.all(color: sticker ? const Color(0xFFE5C95A) : K.simLine),
                      borderRadius: BorderRadius.circular(sticker ? 4 : 10),
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(1, 3))],
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      QrImageView(data: s.str('url'), size: 170, backgroundColor: Colors.transparent),
                      if (_scanning)
                        Positioned.fill(
                          child: Container(decoration: BoxDecoration(border: Border.all(color: K.teal, width: 2), borderRadius: BorderRadius.circular(6))),
                        ),
                      if (_scanning)
                        Container(height: 3, width: 170, color: K.teal)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(begin: -84, end: 84, duration: 500.ms, curve: Curves.easeInOut),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (show) ...[
                Text(l.qrLeadsTo, style: const TextStyle(color: K.simMuted, fontSize: 13)),
                const SizedBox(height: 6),
                FlagHighlight(
                  active: p.isFlagged('url'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: K.simBg2, borderRadius: BorderRadius.circular(8)),
                    child: Text.rich(urlSpan(s.str('url')), style: const TextStyle(fontFamily: K.mono, fontSize: 13, color: K.simInk)),
                  ),
                ).animate().fadeIn(),
              ] else
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF29527A), foregroundColor: Colors.white),
                  onPressed: _scanning ? null : _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.qrScan),
                ),
            ]),
          ),
        ),
        if (show)
          ActionBar(
            onAction: p.onAction,
            actions: [
              SimAction('scan_open', l.qrOpen, Icons.open_in_browser),
              SimAction('ignore', l.qrIgnore, Icons.block),
              SimAction('report', l.actReport, Icons.flag, primary: true),
            ],
          ),
      ]),
    );
  }
}

/// MFA fatigue: the prompts keep coming, and each one makes "approve" more tempting.
class PushSim extends StatefulWidget {
  const PushSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  State<PushSim> createState() => _PushSimState();
}

class _PushSimState extends State<PushSim> {
  int _count = 0;
  Timer? _timer;

  int get _total => (widget.s.content['repeat'] as num?)?.toInt() ?? 1;

  @override
  void initState() {
    super.initState();
    if (widget.props.onAction == null) {
      _count = _total;
      return;
    }
    _tick();
    _timer = Timer.periodic(const Duration(milliseconds: 950), (t) {
      if (_count >= _total) {
        t.cancel();
        return;
      }
      _tick();
    });
  }

  void _tick() {
    setState(() => _count++);
    HapticFeedback.heavyImpact();
    Sfx.play('buzz', volume: 0.6);
  }

  @override
  void didUpdateWidget(PushSim old) {
    super.didUpdateWidget(old);
    if (widget.props.answered) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = widget.s;
    final p = widget.props;
    return Container(
      color: const Color(0xFF16222E),
      child: Column(children: [
        ContextBanner(text: s.str('context')),
        const SizedBox(height: 18),
        const Text('22:47', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w500, fontSize: 52, color: Colors.white)),
        Expanded(
          child: Stack(alignment: Alignment.topCenter, children: [
            for (var i = 0; i < _count.clamp(0, 6); i++)
              Positioned(
                top: 14.0 + (5 - (_count.clamp(0, 6) - 1 - i)) * 7.0,
                left: 18.0 + (_count.clamp(0, 6) - 1 - i) * 5.0,
                right: 18.0 + (_count.clamp(0, 6) - 1 - i) * 5.0,
                child: _Notification(s: s, front: i == _count.clamp(0, 6) - 1, count: _count, props: p).animate(key: ValueKey('$i-${_count > i}')).fadeIn(duration: 160.ms).slideY(begin: -0.3, end: 0, duration: 220.ms),
              ),
          ]),
        ),
        ActionBar(
          onAction: p.onAction,
          actions: [
            SimAction('approve', l.pushApprove, Icons.check_circle_outline),
            SimAction('deny', l.pushDeny, Icons.cancel_outlined),
            SimAction('report', l.actReport, Icons.flag, primary: true),
          ],
        ),
      ]),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({required this.s, required this.front, required this.count, required this.props});
  final Scenario s;
  final bool front;
  final int count;
  final SimProps props;

  @override
  Widget build(BuildContext context) {
    return FlagHighlight(
      active: front && (props.isFlagged('note:spam') || props.isFlagged('note:unasked')),
      radius: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF29527A)),
            const SizedBox(width: 6),
            Expanded(child: Text(s.str('app'), style: const TextStyle(color: K.simMuted, fontSize: 12.5, fontWeight: FontWeight.w600))),
            if (count > 1) Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFD92D3F), borderRadius: BorderRadius.circular(99)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(s.str('title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: K.simInk)),
          const SizedBox(height: 2),
          Text(s.str('body'), style: const TextStyle(color: K.simMuted, fontSize: 13.5, height: 1.35)),
        ]),
      ),
    );
  }
}

/// File manager: what the file calls itself, and what it really is.
class FileSim extends StatefulWidget {
  const FileSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  @override
  State<FileSim> createState() => _FileSimState();
}

class _FileSimState extends State<FileSim> {
  bool _details = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = widget.s;
    final p = widget.props;
    final display = s.str('display_name').isNotEmpty ? s.str('display_name') : s.str('name');
    final showDetails = _details || p.answered;
    return ColoredBox(
      color: K.simBg,
      child: Column(children: [
        ContextBanner(text: s.str('context')),
        Container(
          width: double.infinity,
          color: K.simBg2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(l.fileDownloads, style: const TextStyle(color: K.simMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: p.onAction == null ? null : () => p.onAction!('open_attachment'),
                child: FlagHighlight(
                  active: p.isFlagged('name'),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      const Icon(Icons.insert_drive_file_outlined, size: 40, color: Color(0xFF29527A)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(display, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: K.simInk, fontFamily: K.mono)),
                          const SizedBox(height: 2),
                          Text('${(s.content['size_kb'] as num).toInt()} KB', style: const TextStyle(color: K.simMuted, fontSize: 12.5)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: K.simLink),
                  onPressed: () {
                    Sfx.click();
                    setState(() => _details = !_details);
                  },
                  icon: Icon(showDetails ? Icons.expand_less : Icons.info_outline, size: 18),
                  label: Text(l.fileDetails),
                ),
              ),
              if (showDetails)
                FlagHighlight(
                  active: p.isFlagged('note:type') || p.isFlagged('note:size'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: K.simBg2, borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${l.fileRealName}: ${s.str('name')}', style: const TextStyle(fontFamily: K.mono, fontSize: 13, color: K.simInk)),
                      const SizedBox(height: 4),
                      Text('${l.fileType}: ${s.str('shown_type')}', style: const TextStyle(fontSize: 13.5, color: K.simInk, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ).animate().fadeIn(),
            ]),
          ),
        ),
        ActionBar(
          onAction: p.onAction,
          actions: [
            SimAction('open_attachment', l.actOpen, Icons.open_in_new),
            SimAction('delete', l.actDelete, Icons.delete_outline),
            SimAction('report', l.actReport, Icons.flag, primary: true),
          ],
        ),
      ]),
    );
  }
}

/// Situations that are no message at all: a USB stick, a door, a café network.
class SceneSim extends StatelessWidget {
  const SceneSim({super.key, required this.s, required this.props});
  final Scenario s;
  final SimProps props;

  static const _icons = {
    'usb': Icons.usb,
    'wifi': Icons.wifi,
    'laptop': Icons.laptop_mac,
    'door': Icons.door_front_door_outlined,
    'alert': Icons.warning_amber_rounded,
    'people': Icons.groups_2_outlined,
    'key': Icons.key,
  };

  @override
  Widget build(BuildContext context) {
    final options = s.list('options');
    return ColoredBox(
      color: K.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [K.surface2, K.tealDim]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_icons[s.str('icon')] ?? Icons.help_outline, size: 64, color: K.teal),
          ),
          const SizedBox(height: 16),
          Text(s.str('title'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(s.str('text'), style: const TextStyle(fontSize: 15.5, height: 1.45, color: K.ink)),
          const SizedBox(height: 16),
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), alignment: Alignment.centerLeft),
                onPressed: props.onAction == null ? null : () => props.onAction!(o['id'] as String),
                child: Text(o['label'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)),
              ),
            ),
        ]),
      ),
    );
  }
}
