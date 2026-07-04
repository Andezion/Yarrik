import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.value, this.size = 42});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: value / 100, color: color),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.31,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3.4;
    final track = Paint()
      ..color = const Color(0xFF1F7FD1).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    const startAngle = -1.5707963267948966; 
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progress * 6.283185307179586,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
