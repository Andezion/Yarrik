import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import 'chart_point.dart';
import 'empty_chart.dart';

class LineSeries {
  const LineSeries({required this.points, required this.color, this.area = false});
  final List<ChartPoint> points;
  final Color color;
  final bool area;
}

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.series,
    this.height = 210,
    this.lo,
    this.hi,
    this.formatY,
    this.refLine,
    this.refLabel,
  });

  final List<LineSeries> series;
  final double height;
  final double? lo;
  final double? hi;
  final String Function(double)? formatY;
  final double? refLine;
  final String? refLabel;

  @override
  Widget build(BuildContext context) {
    final hasData = series.any((s) => s.points.isNotEmpty);
    if (!hasData) return EmptyChart(height: height);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(
          series: series,
          lo: lo,
          hi: hi,
          formatY: formatY ?? (v) => v.round().toString(),
          refLine: refLine,
          refLabel: refLabel,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.lo,
    required this.hi,
    required this.formatY,
    required this.refLine,
    required this.refLabel,
  });

  final List<LineSeries> series;
  final double? lo;
  final double? hi;
  final String Function(double) formatY;
  final double? refLine;
  final String? refLabel;

  static const _pl = 42.0, _pr = 14.0, _pt = 14.0, _pb = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final iw = size.width - _pl - _pr;
    final ih = size.height - _pt - _pb;

    final allValues = [for (final s in series) for (final p in s.points) p.value];
    final mn = allValues.reduce((a, b) => a < b ? a : b);
    final mx = allValues.reduce((a, b) => a > b ? a : b);
    var loV = lo ?? (mn - (mx - mn) * 0.15 - 1);
    var hiV = hi ?? (mx + (mx - mn) * 0.15 + 1);
    if (hiV - loV < 4) hiV = loV + 4;

    double y(double v) => _pt + ih - (v - loV) / (hiV - loV) * ih;
    double x(int i, int len) => len <= 1 ? _pl + iw / 2 : _pl + iw * i / (len - 1);

    final gridPaint = Paint()
      ..color = const Color(0xFF5091C8).withValues(alpha: 0.22)
      ..strokeWidth = 1;
    final axisStyle = TextStyle(color: AppColors.dim, fontSize: 10);

    for (var i = 0; i <= 4; i++) {
      final v = loV + (hiV - loV) * i / 4;
      final yy = y(v);
      _drawDashedLine(canvas, Offset(_pl, yy), Offset(size.width - _pr, yy), gridPaint);
      _drawText(canvas, formatY(v), Offset(_pl - 7, yy - 6), axisStyle, alignRight: true);
    }

    for (final s in series) {
      if (s.points.isEmpty) continue;
      final pts = [
        for (var i = 0; i < s.points.length; i++)
          Offset(x(i, s.points.length), y(s.points[i].value))
      ];

      if (s.area && pts.length > 1) {
        final areaPath = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (final p in pts.skip(1)) {
          areaPath.lineTo(p.dx, p.dy);
        }
        areaPath.lineTo(pts.last.dx, _pt + ih);
        areaPath.lineTo(pts.first.dx, _pt + ih);
        areaPath.close();
        final areaPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [s.color.withValues(alpha: 0.28), s.color.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, _pt, size.width, ih));
        canvas.drawPath(areaPath, areaPaint);
      }

      if (pts.length > 1) {
        final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (final p in pts.skip(1)) {
          linePath.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(
          linePath,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      for (final p in pts) {
        canvas.drawCircle(p, 3.6, Paint()..color = s.color);
        canvas.drawCircle(
          p,
          3.6,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    var ref = series.first.points;
    for (final s in series) {
      if (s.points.length > ref.length) ref = s.points;
    }
    if (ref.isNotEmpty) {
      final step = (ref.length / 6).ceil().clamp(1, ref.length);
      for (var i = 0; i < ref.length; i++) {
        if (i % step == 0 || i == ref.length - 1) {
          _drawText(
            canvas,
            ref[i].label,
            Offset(x(i, ref.length), size.height - 18),
            axisStyle,
            alignCenter: true,
          );
        }
      }
    }

    if (refLine != null && refLine! > loV && refLine! < hiV) {
      final ry = y(refLine!);
      final refPaint = Paint()
        ..color = const Color(0xFFF2A93B).withValues(alpha: 0.7)
        ..strokeWidth = 1.4;
      _drawDashedLine(canvas, Offset(_pl, ry), Offset(size.width - _pr, ry), refPaint, dash: 6, gap: 5);
      if (refLabel != null) {
        _drawText(
          canvas,
          refLabel!,
          Offset(size.width - _pr, ry - 14),
          const TextStyle(color: Color(0xFFF2A93B), fontSize: 10),
          alignRight: true,
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint, {double dash = 2, double gap = 5}) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var covered = 0.0;
    while (covered < total) {
      final segEnd = (covered + dash).clamp(0, total);
      canvas.drawLine(a + dir * covered, a + dir * segEnd.toDouble(), paint);
      covered += dash + gap;
    }
  }

  void _drawText(Canvas canvas, String text, Offset topLeftish, TextStyle style,
      {bool alignRight = false, bool alignCenter = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    var offset = topLeftish;
    if (alignRight) offset = Offset(topLeftish.dx - painter.width, topLeftish.dy);
    if (alignCenter) offset = Offset(topLeftish.dx - painter.width / 2, topLeftish.dy);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}
