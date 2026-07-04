import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import 'chart_point.dart';
import 'empty_chart.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.points,
    this.height = 200,
    this.colorTop = const Color(0xFF2E97E5),
    this.colorBottom = const Color(0xFF1F7FD1),
    this.formatY,
  });

  final List<ChartPoint> points;
  final double height;
  final Color colorTop;
  final Color colorBottom;
  final String Function(double)? formatY;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.value <= 0)) {
      return EmptyChart(height: height);
    }
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _BarChartPainter(
          points: points,
          colorTop: colorTop,
          colorBottom: colorBottom,
          formatY: formatY ?? (v) => v.round().toString(),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.points,
    required this.colorTop,
    required this.colorBottom,
    required this.formatY,
  });

  final List<ChartPoint> points;
  final Color colorTop;
  final Color colorBottom;
  final String Function(double) formatY;

  static const _pl = 42.0, _pr = 10.0, _pt = 12.0, _pb = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final iw = size.width - _pl - _pr;
    final ih = size.height - _pt - _pb;
    final mx = points.map((p) => p.value).reduce((a, b) => a > b ? a : b) * 1.12;
    final maxV = mx == 0 ? 1.0 : mx;

    final gridPaint = Paint()
      ..color = const Color(0xFF5091C8).withValues(alpha: 0.22)
      ..strokeWidth = 1;
    final axisStyle = TextStyle(color: AppColors.dim, fontSize: 10);

    for (var i = 0; i <= 3; i++) {
      final v = maxV * i / 3;
      final yy = _pt + ih - v / maxV * ih;
      _drawDashed(canvas, Offset(_pl, yy), Offset(size.width - _pr, yy), gridPaint);
      _drawText(canvas, formatY(v), Offset(_pl - 7, yy - 6), axisStyle, alignRight: true);
    }

    final barWidth = (iw / points.length * 0.62).clamp(0, 34).toDouble();
    for (var i = 0; i < points.length; i++) {
      final v = points[i].value;
      final cx = _pl + iw * (i + 0.5) / points.length;
      final bh = (v / maxV * ih).clamp(1, ih).toDouble();
      final rect = Rect.fromLTWH(cx - barWidth / 2, _pt + ih - bh, barWidth, bh);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorTop, colorBottom.withValues(alpha: 0.45)],
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);

      if (points.length <= 8 || i % 2 == 0) {
        _drawText(
          canvas,
          points[i].label,
          Offset(cx, size.height - 18),
          axisStyle,
          alignCenter: true,
        );
      }
    }
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint paint, {double dash = 2, double gap = 5}) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var covered = 0.0;
    while (covered < total) {
      final segEnd = (covered + dash).clamp(0, total);
      canvas.drawLine(a + dir * covered, a + dir * segEnd.toDouble(), paint);
      covered += dash + gap;
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style,
      {bool alignRight = false, bool alignCenter = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    var offset = pos;
    if (alignRight) offset = Offset(pos.dx - painter.width, pos.dy);
    if (alignCenter) offset = Offset(pos.dx - painter.width / 2, pos.dy);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}
