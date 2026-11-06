import 'package:flutter/material.dart';

import 'theme.dart';

/// On a phone the app fills the screen. On a laptop or projector it stands in a phone on a dark grid.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  static const double _width = 430;
  static const double _maxHeight = 900;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < 620) return child;
    final height = size.height < _maxHeight + 48 ? size.height - 24 : _maxHeight;
    return ColoredBox(
      color: K.bg,
      child: CustomPaint(
        painter: _GridPainter(),
        child: Center(
          child: Container(
            width: _width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              border: Border.all(color: K.surface2, width: 8),
              boxShadow: [BoxShadow(color: K.teal.withValues(alpha: 0.14), blurRadius: 70, spreadRadius: 4)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(size: Size(_width - 16, height - 16)),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = K.teal.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
