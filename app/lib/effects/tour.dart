import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import 'mascot.dart';

/// One stop of a guided tour. Without a [target] the fish speaks in the middle of the dark screen.
class TourStep {
  const TourStep({this.target, required this.title, required this.body, this.mood = MascotMood.happy, this.slice, this.padding = 8});

  final GlobalKey? target;
  final String title;
  final String body;
  final MascotMood mood;

  /// Highlights one of several equal parts of the target, for example one tab of the navigation bar: (index, count).
  final (int, int)? slice;
  final double padding;
}

/// Dims the screen, cuts a lit hole around one element after another, and lets the fish explain each of them.
/// Completes when the player finishes or skips the tour.
Future<void> runTour(BuildContext context, List<TourStep> steps) {
  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TourLayer(
      steps: steps,
      onDone: () {
        entry.remove();
        if (!done.isCompleted) done.complete();
      },
    ),
  );
  Overlay.of(context).insert(entry);
  return done.future;
}

class _TourLayer extends StatefulWidget {
  const _TourLayer({required this.steps, required this.onDone});
  final List<TourStep> steps;
  final VoidCallback onDone;

  @override
  State<_TourLayer> createState() => _TourLayerState();
}

class _TourLayerState extends State<_TourLayer> {
  int _i = 0;
  Rect? _hole;
  bool _measured = false;

  TourStep get _step => widget.steps[_i];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _arrive());
  }

  /// Scrolls the element into view, then measures where it ended up.
  Future<void> _arrive() async {
    final target = _step.target?.currentContext;
    if (target != null && target.mounted && Scrollable.maybeOf(target) != null) {
      await Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic, alignment: 0.32);
    }
    if (!mounted) return;
    setState(() {
      _hole = _measure();
      _measured = true;
    });
  }

  Rect? _measure() {
    final box = _step.target?.currentContext?.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return null;
    var rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final slice = _step.slice;
    if (slice != null) {
      final w = rect.width / slice.$2;
      rect = Rect.fromLTWH(rect.left + w * slice.$1, rect.top, w, rect.height);
    }
    // A long element, such as the learning path, is lit only as far as the screen shows it.
    rect = rect.intersect(Offset.zero & overlay.size);
    return rect.inflate(_step.padding);
  }

  void _next() {
    Sfx.click();
    if (_i >= widget.steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _i++;
      _measured = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _arrive());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final last = _i == widget.steps.length - 1;
    return LayoutBuilder(builder: (context, c) {
      final size = c.biggest;
      final hole = _step.target == null ? null : _hole;
      // The bubble goes where there is more room.
      final below = hole != null && hole.center.dy < size.height * 0.5;
      final bubble = Semantics(
        liveRegion: true,
        child: _Bubble(
          key: ValueKey(_i),
          step: _step,
          index: _i,
          count: widget.steps.length,
          nextLabel: last ? l.tourDone : l.next,
          skipLabel: l.tourSkip,
          onNext: _next,
          onSkip: last ? null : widget.onDone,
        ),
      );
      return Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          // The scrim swallows all touches: during the tour only its buttons respond.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: TweenAnimationBuilder<Rect?>(
                // No target: the hole closes to nothing in the middle of the screen.
                tween: RectTween(end: hole ?? Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0)),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, r, _) => CustomPaint(painter: _ScrimPainter(hole: r)),
              ),
            ),
          ),
          if (_measured)
            if (hole == null)
              Center(child: Padding(padding: const EdgeInsets.all(18), child: bubble))
            else if (below)
              Positioned(left: 14, right: 14, top: (hole.bottom + 14).clamp(14.0, size.height - 260), child: bubble)
            else
              Positioned(left: 14, right: 14, bottom: (size.height - hole.top + 14).clamp(14.0, size.height - 260), child: bubble),
        ]),
      );
    });
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({required this.hole});
  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = const Color(0xD9050A12);
    final r = hole;
    if (r == null || r.isEmpty) {
      canvas.drawRect(Offset.zero & size, scrim);
      return;
    }
    final rounded = RRect.fromRectAndRadius(r, const Radius.circular(16));
    // Even-odd, not Path.combine: on the web a hole that touches no screen edge came out filled in.
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(rounded),
      scrim,
    );
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = K.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3),
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole;
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.step, required this.index, required this.count, required this.nextLabel, required this.skipLabel, required this.onNext, required this.onSkip});
  final TourStep step;
  final int index;
  final int count;
  final String nextLabel;
  final String skipLabel;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
      decoration: BoxDecoration(
        color: K.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: K.teal.withValues(alpha: 0.7)),
        boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Mascot(mood: step.mood, size: 70),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.title, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 4),
              Text(step.body, style: const TextStyle(fontSize: 14.5, height: 1.38, color: K.ink)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          for (var i = 0; i < count; i++)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(shape: BoxShape.circle, color: i == index ? K.teal : K.surface2),
            ),
          const Spacer(),
          if (onSkip != null) TextButton(onPressed: onSkip, child: Text(skipLabel, style: const TextStyle(color: K.muted))),
          const SizedBox(width: 4),
          FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(84, 42)), autofocus: true, onPressed: onNext, child: Text(nextLabel)),
        ]),
      ]),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.06, end: 0, duration: 240.ms, curve: Curves.easeOutCubic);
  }
}
