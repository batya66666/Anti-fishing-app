import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import 'mascot.dart';

/// Wraps the whole app: it can be photographed and torn apart by the shader.
final appBoundaryKey = GlobalKey();

final hackProvider = NotifierProvider<HackController, HackRequest?>(HackController.new);

/// What went wrong decides what the calm screen says afterwards.
enum HackKind { attack, paranoid, missed }

class HackRequest {
  HackRequest(this.snapshot, this.done, this.kind, this.short);
  final ui.Image? snapshot;
  final Completer<void> done;
  final HackKind kind;

  /// A second of glitch and a stamp, for modes where the clock is running.
  final bool short;
}

class HackController extends Notifier<HackRequest?> {
  @override
  HackRequest? build() => null;

  /// Plays the sequence. The future completes when the player dismisses it, or by itself when [short].
  Future<void> play({HackKind kind = HackKind.attack, bool short = false}) async {
    if (state != null) return; // rapid mistakes in swipe mode do not stack up
    ui.Image? image;
    try {
      final boundary = appBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      image = await boundary?.toImage(pixelRatio: 1);
    } catch (_) {
      // Without a snapshot the glitch simply runs over noise.
    }
    final done = Completer<void>();
    state = HackRequest(image, done, kind, short);
    await done.future;
    state = null;
  }
}

/// The main "wow" moment: glitch, fake ransomware screen, then a calm explanation that this was training.
class HackedLayer extends ConsumerWidget {
  const HackedLayer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(hackProvider);
    return Stack(children: [
      RepaintBoundary(key: appBoundaryKey, child: child),
      if (request != null)
        Positioned.fill(
          child: request.kind == HackKind.paranoid ? _ParanoidSequence(key: ValueKey(request), request: request) : _HackedSequence(key: ValueKey(request), request: request),
        ),
    ]);
  }
}

/// You raised the alarm over a genuine message. Nobody got hacked, so there is no ransom screen:
/// red flags rain down on a very nervous fish.
class _ParanoidSequence extends StatefulWidget {
  const _ParanoidSequence({super.key, required this.request});
  final HackRequest request;

  @override
  State<_ParanoidSequence> createState() => _ParanoidSequenceState();
}

class _ParanoidSequenceState extends State<_ParanoidSequence> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  final List<Timer> _timers = [];
  bool _calm = false;
  static const _flags = 34;

  @override
  void initState() {
    super.initState();
    Sfx.play('buzz', volume: 0.8);
    HapticFeedback.mediumImpact();
    if (widget.request.short) {
      _timers.add(Timer(const Duration(milliseconds: 1250), () {
        if (!widget.request.done.isCompleted) widget.request.done.complete();
      }));
    } else {
      _timers.add(Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _calm = true);
      }));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _c.dispose();
    widget.request.snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (_calm) return _CalmScreen(kind: HackKind.paranoid, onContinue: () => widget.request.done.complete());
    return Material(
      color: const Color(0xF23A2A05),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _FlagRainPainter(_c.value, _flags))),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Transform.rotate(angle: sin(_c.value * 2 * pi * 14) * 0.07, child: const Mascot(mood: MascotMood.worried, size: 150)),
              const SizedBox(height: 10),
              Transform.scale(
                scale: 1 + sin(_c.value * 2 * pi * 4) * 0.03,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l.paranoidTitle, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 46, color: Color(0xFFFFD166), height: 1)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(l.paranoidSub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FlagRainPainter extends CustomPainter {
  _FlagRainPainter(this.t, this.count);
  final double t;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final icon = Icons.flag;
    for (var i = 0; i < count; i++) {
      final r = Random(i);
      final speed = 0.6 + r.nextDouble();
      final y = ((t * speed + r.nextDouble()) % 1) * (size.height + 60) - 30;
      final x = r.nextDouble() * size.width + sin(t * 2 * pi * 2 + i) * 10;
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: 16 + r.nextDouble() * 18, color: const Color(0xFFFF4D5E).withValues(alpha: 0.35 + r.nextDouble() * 0.4)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(_FlagRainPainter old) => old.t != t;
}

class _HackedSequence extends StatefulWidget {
  const _HackedSequence({super.key, required this.request});
  final HackRequest request;

  @override
  State<_HackedSequence> createState() => _HackedSequenceState();
}

enum _Stage { glitch, stamp, ransom, calm }

class _HackedSequenceState extends State<_HackedSequence> with TickerProviderStateMixin {
  _Stage _stage = _Stage.glitch;
  ui.FragmentShader? _shader;
  late final AnimationController _glitch = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _loadShader();
    Sfx.play('glitch', volume: 1);
    HapticFeedback.heavyImpact();
    if (widget.request.short) {
      _glitch.duration = const Duration(milliseconds: 600);
      _glitch.forward();
      _timers.add(Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _stage = _Stage.stamp);
        Sfx.play('error', volume: 0.7);
      }));
      _timers.add(Timer(const Duration(milliseconds: 1250), () {
        if (!widget.request.done.isCompleted) widget.request.done.complete();
      }));
      return;
    }
    _glitch.forward();
    _timers.add(Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _stage = _Stage.ransom);
      Sfx.play('alarm', volume: 1);
      _shake.repeat();
      for (var i = 0; i < 6; i++) {
        _timers.add(Timer(Duration(milliseconds: i * 280), HapticFeedback.heavyImpact));
      }
    }));
    _timers.add(Timer(const Duration(milliseconds: 5200), () {
      if (!mounted) return;
      _shake.stop();
      setState(() => _stage = _Stage.calm);
    }));
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/glitch.frag');
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // Falls back to the plain painter below.
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _glitch.dispose();
    _shake.dispose();
    widget.request.snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.glitch => AnimatedBuilder(
          animation: _glitch,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _GlitchPainter(_shader, widget.request.snapshot, _glitch.value),
          ),
        ),
      _Stage.ransom => ColoredBox(
          color: const Color(0xFF3B0509),
          child: AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final dx = sin(_shake.value * 2 * pi * 6) * 5;
              final dy = cos(_shake.value * 2 * pi * 4) * 3;
              return Transform.translate(offset: Offset(dx, dy), child: child);
            },
            child: const _RansomScreen(),
          ),
        ),
      _Stage.stamp => const _HackedStamp(),
      _Stage.calm => _CalmScreen(kind: widget.request.kind, onContinue: () => widget.request.done.complete()),
    };
  }
}

class _GlitchPainter extends CustomPainter {
  _GlitchPainter(this.shader, this.image, this.t);
  final ui.FragmentShader? shader;
  final ui.Image? image;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final s = shader;
    final img = image;
    if (s != null && img != null) {
      s.setFloat(0, size.width);
      s.setFloat(1, size.height);
      s.setFloat(2, t * 1.5);
      s.setFloat(3, Curves.easeIn.transform(t).clamp(0.08, 1.0));
      s.setImageSampler(0, img);
      canvas.drawRect(rect, Paint()..shader = s);
      return;
    }
    // Fallback without shader support: tearing bars over black.
    canvas.drawRect(rect, Paint()..color = Color.lerp(Colors.transparent, const Color(0xFF200408), t)!);
    final r = Random((t * 40).floor());
    for (var i = 0; i < 22; i++) {
      final y = r.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(r.nextDouble() * size.width * 0.4, y, size.width * r.nextDouble(), 4 + r.nextDouble() * 22),
        Paint()..color = (r.nextBool() ? K.danger : Colors.white).withValues(alpha: 0.25 + 0.6 * r.nextDouble()),
      );
    }
  }

  @override
  bool shouldRepaint(_GlitchPainter old) => old.t != t || old.shader != shader;
}

class _RansomScreen extends StatefulWidget {
  const _RansomScreen();

  @override
  State<_RansomScreen> createState() => _RansomScreenState();
}

class _RansomScreenState extends State<_RansomScreen> {
  static const _files = [
    'Rechnungen_2026.xlsx',
    'Personalakten.zip',
    'Kundenliste_final.xlsx',
    'Vertrag_Kessler.pdf',
    'Lohnabrechnung_Okt.pdf',
    'Backup_Server_03.vhd',
    'Projekt_Mosel.pptx',
    'SAP_Export_Q3.csv',
    'Passwoerter_ALT.docx',
    'Angebote_Q4.xlsx',
  ];
  late final Timer _ticker;
  int _n = 0;
  int _seconds = 71 * 3600 + 59 * 60 + 59;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 180), (t) {
      setState(() {
        _n++;
        if (_n % 5 == 0) _seconds--;
      });
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String get _clock {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final flash = _n % 6 < 3;
    return Material(
      color: flash ? const Color(0xFF7A0A18) : const Color(0xFF3B0509),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 72),
                  const SizedBox(height: 14),
                  Text(l.hackedTitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 46, color: Colors.white, height: 1)),
                  const SizedBox(height: 10),
                  Text(l.hackedSubtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < 6; i++)
                          Text(
                            '${_files[(_n + i) % _files.length]}  ->  .locked',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(fontFamily: K.mono, fontSize: 13, color: Color(0xFFFF9AA5)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l.hackedPay, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(_clock, style: const TextStyle(fontFamily: K.mono, fontWeight: FontWeight.w700, fontSize: 44, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HackedStamp extends StatelessWidget {
  const _HackedStamp();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC3B0509),
      child: Center(
        child: Transform.rotate(
          angle: -0.14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 5), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock, color: Colors.white, size: 42),
              const SizedBox(width: 12),
              Text(context.l.hackedTitle, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 48, color: Colors.white, height: 1)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CalmScreen extends StatelessWidget {
  const _CalmScreen({required this.kind, required this.onContinue});
  final HackKind kind;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: K.bg,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Mascot(mood: kind == HackKind.paranoid ? MascotMood.worried : MascotMood.hooked, size: 160),
                  const SizedBox(height: 18),
                  Text(kind == HackKind.paranoid ? l.paranoidCalmTitle : l.calmTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(switch (kind) { HackKind.attack => l.calmBody, HackKind.paranoid => l.hackedFalseAlarmBody, HackKind.missed => l.hackedMissedBody }, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16, height: 1.45)),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      autofocus: true,
                      onPressed: onContinue,
                      icon: const Icon(Icons.flag),
                      label: Text(kind == HackKind.paranoid ? l.paranoidButton : l.calmButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
