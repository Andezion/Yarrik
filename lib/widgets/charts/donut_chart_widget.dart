import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import 'empty_chart.dart';

class DonutSlice {
  const DonutSlice({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;
}

class DonutChartWidget extends StatelessWidget {
  const DonutChartWidget({super.key, required this.slices, this.centerUnitLabel = 'подходов'});

  final List<DonutSlice> slices;
  final String centerUnitLabel;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (a, s) => a + s.value);
    if (total == 0) return const EmptyChart(height: 160, message: 'Нет данных.');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    centerUnitLabel,
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          '${s.label} · ${(s.value / total * 100).round()}%',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.total});

  final List<DonutSlice> slices;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    var startAngle = -1.5707963267948966;
    for (final s in slices) {
      final sweep = s.value / total * 6.283185307179586;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;
      final adjust = sweep > 0.02 ? 0.01 : 0.0; 
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + adjust,
        sweep - adjust * 2,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
