import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';

enum MascotMood { happy, neutral, worried, hooked, cheering }

/// Köbi, the fish who does not take the bait. Drawn in code, so it stays sharp everywhere and needs no asset.
class Mascot extends StatefulWidget {
  const Mascot({super.key, this.mood = MascotMood.neutral, this.size = 96});
  final MascotMood mood;
  final double size;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _FishPainter(_c.value, widget.mood)),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter(this.t, this.mood);
  final double t;
  final MascotMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final wave = sin(t * 2 * pi);
    final speed = mood == MascotMood.cheering ? 3.0 : 1.0;
    final bob = sin(t * 2 * pi * speed) * w * (mood == MascotMood.cheering ? 0.07 : 0.03);
    final tailSwing = sin(t * 2 * pi * 2 * speed) * 0.25;

    // Bubbles rising.
    final bubble = Paint()..color = K.teal.withValues(alpha: 0.35);
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      canvas.drawCircle(Offset(w * (0.82 + 0.05 * sin(p * 9 + i)), w * (0.56 - p * 0.5)), w * (0.012 + 0.012 * i), bubble..color = K.teal.withValues(alpha: 0.4 * (1 - p)));
    }

    canvas.save();
    final tilt = mood == MascotMood.hooked ? -0.45 : wave * 0.04;
    canvas.translate(w * 0.5, w * 0.55 + bob);
    canvas.rotate(tilt);

    final bodyColor = switch (mood) {
      MascotMood.worried => const Color(0xFF8BD8CC),
      MascotMood.hooked => const Color(0xFFFF9AA5),
      _ => K.teal,
    };

    // Tail.
    canvas.save();
    canvas.translate(-w * 0.26, 0);
    canvas.rotate(tailSwing);
    final tail = Path()
      ..moveTo(w * 0.02, 0)
      ..quadraticBezierTo(-w * 0.1, -w * 0.05, -w * 0.2, -w * 0.17)
      ..quadraticBezierTo(-w * 0.15, 0, -w * 0.2, w * 0.17)
      ..quadraticBezierTo(-w * 0.1, w * 0.05, w * 0.02, 0)
      ..close();
    canvas.drawPath(tail, Paint()..color = bodyColor.withValues(alpha: 0.85));
    canvas.restore();

    // Top fin.
    final fin = Path()
      ..moveTo(-w * 0.1, -w * 0.17)
      ..quadraticBezierTo(0, -w * 0.33, w * 0.09, -w * 0.18)
      ..close();
    canvas.drawPath(fin, Paint()..color = bodyColor.withValues(alpha: 0.75));

    // Body.
    final body = Rect.fromCenter(center: Offset.zero, width: w * 0.62, height: w * 0.42);
    canvas.drawOval(body, Paint()..color = bodyColor);
    // Belly highlight.
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.03, w * 0.08), width: w * 0.44, height: w * 0.19), Paint()..color = Colors.white.withValues(alpha: 0.28));
    // Side fin.
    final side = Path()
      ..moveTo(-w * 0.04, w * 0.02)
      ..quadraticBezierTo(-w * 0.14 , w * (0.1 + wave * 0.02), -w * 0.03, w * 0.14)
      ..quadraticBezierTo(w * 0.02, w * 0.08, -w * 0.04, w * 0.02)
      ..close();
    canvas.drawPath(side, Paint()..color = K.tealDim.withValues(alpha: 0.5));

    // Eye. Blinks now and then.
    final blink = (t > 0.62 && t < 0.65);
    final eye = Offset(w * 0.16, -w * 0.05);
    final ink = const Color(0xFF06221E);
    if (blink) {
      canvas.drawLine(eye - Offset(w * 0.04, 0), eye + Offset(w * 0.04, 0), Paint()
        ..color = ink
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round);
    } else {
      final eyeR = mood == MascotMood.worried || mood == MascotMood.hooked ? w * 0.062 : w * 0.05;
      canvas.drawCircle(eye, eyeR, Paint()..color = Colors.white);
      canvas.drawCircle(eye + Offset(w * 0.012, 0), eyeR * 0.55, Paint()..color = ink);
    }

    // Mouth.
    final mouth = Path();
    final mp = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case MascotMood.happy || MascotMood.cheering:
        mouth.moveTo(w * 0.17, w * 0.06);
        mouth.quadraticBezierTo(w * 0.24, w * 0.11, w * 0.28, w * 0.04);
      case MascotMood.neutral:
        mouth.moveTo(w * 0.19, w * 0.07);
        mouth.lineTo(w * 0.28, w * 0.06);
      case MascotMood.worried || MascotMood.hooked:
        mouth.moveTo(w * 0.17, w * 0.1);
        mouth.quadraticBezierTo(w * 0.23, w * 0.05, w * 0.28, w * 0.1);
    }
    canvas.drawPath(mouth, mp);
    canvas.restore();

    // The hook: dangling in the water, or stuck in the mouth when things went wrong.
    final hooked = mood == MascotMood.hooked;
    final hookX = hooked ? w * 0.72 : w * (0.9 + wave * 0.01);
    final hookY = hooked ? w * 0.46 : w * 0.3;
    final line = Paint()
      ..color = K.muted.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.008;
    canvas.drawLine(Offset(hookX, 0), Offset(hookX, hookY), line);
    final hookPath = Path()
      ..moveTo(hookX, hookY)
      ..lineTo(hookX, hookY + w * 0.05)
      ..arcToPoint(Offset(hookX - w * 0.07, hookY + w * 0.03), radius: Radius.circular(w * 0.045))
      ..moveTo(hookX - w * 0.07, hookY + w * 0.03)
      ..lineTo(hookX - w * 0.05, hookY + w * 0.055);
    canvas.drawPath(hookPath, Paint()
      ..color = K.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_FishPainter old) => old.t != t || old.mood != mood;
}
