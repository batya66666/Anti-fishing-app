import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A one-shot burst. Place it in a Stack above the content; it ignores touches.
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.count = 90, this.origin = const Alignment(0, -0.1)});
  final int count;
  final Alignment origin;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _Piece {
  _Piece(Random r)
      : angle = r.nextDouble() * 2 * pi,
        speed = 0.35 + r.nextDouble() * 0.9,
        spin = (r.nextDouble() - 0.5) * 14,
        size = 5 + r.nextDouble() * 7,
        round = r.nextBool(),
        color = const [K.teal, K.warn, K.violet, K.blue, Color(0xFFFF7BAC), Colors.white][r.nextInt(6)];
  final double angle;
  final double speed;
  final double spin;
  final double size;
  final bool round;
  final Color color;
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _pieces = List.generate(widget.count, (_) => _Piece(r));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_c.value, _pieces, widget.origin)),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.pieces, this.origin);
  final double t;
  final List<_Piece> pieces;
  final Alignment origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final o = origin.alongSize(size);
    final reach = min(size.width, size.height) * 0.75;
    for (final p in pieces) {
      final ease = 1 - pow(1 - t, 3).toDouble();
      final gravity = t * t * size.height * 0.6;
      final pos = o + Offset(cos(p.angle), sin(p.angle)) * (reach * p.speed * ease) + Offset(0, gravity);
      final paint = Paint()..color = p.color.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
