import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:truckchecklist/global.dart';


class HexagonBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double hexagonHeight = h;
    final double hexagonWidth = w;

    path.moveTo(hexagonWidth / 1, 0);
    path.lineTo(hexagonWidth, hexagonHeight * 0.25);
    path.lineTo(hexagonWidth, hexagonHeight * 0.75);
    path.lineTo(hexagonWidth / 1, hexagonHeight);
    path.lineTo(0, hexagonHeight * 0.75);
    path.lineTo(0, hexagonHeight * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
