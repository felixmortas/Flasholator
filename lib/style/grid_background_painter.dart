import 'package:flasholator/style/app_colors.dart';
import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;
  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = AppColors.sheetBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final Paint gridPaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 0.5;

    final Paint marginPaint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 1.5;

    const double step = 20; // Taille des carreaux

    // Lignes verticales bleues
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Lignes horizontales bleues
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Ligne rouge de marge (à gauche)
    canvas.drawLine(const Offset(40, 0), Offset(40, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
