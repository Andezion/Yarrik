import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';


class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.skyGradient,
              stops: AppColors.skyGradientStops,
            ),
          ),
        ),
        const IgnorePointer(child: _StaticGlare()),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _BubblesPainter(progress: _controller.value),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _StaticGlare extends StatelessWidget {
  const _StaticGlare();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GlarePainter());
  }
}

class _GlarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void radial(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawRect(Offset.zero & size, paint);
    }

    radial(Offset(size.width * 0.12, 0), size.width * 0.42,
        Colors.white.withValues(alpha: 0.55));
    radial(Offset(size.width * 0.22, size.height * 0.11), size.width * 0.3,
        Colors.white.withValues(alpha: 0.5));
    radial(Offset(size.width * 0.57, size.height * 0.07), size.width * 0.22,
        Colors.white.withValues(alpha: 0.45));
    radial(Offset(size.width * 0.88, size.height * 0.15), size.width * 0.34,
        Colors.white.withValues(alpha: 0.4));
    radial(Offset(size.width * 0.52, size.height * 1.1), size.width * 0.7,
        const Color(0xFF66E0D1).withValues(alpha: 0.28));
    radial(Offset(size.width * 0.06, size.height * 1.06), size.width * 0.5,
        const Color(0xFF8EEA8A).withValues(alpha: 0.3));
    radial(Offset(size.width * 0.96, size.height * 1.05), size.width * 0.5,
        const Color(0xFF8EEA8A).withValues(alpha: 0.22));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BubblesPainter extends CustomPainter {
  _BubblesPainter({required this.progress});

  final double progress; 

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    final rnd = math.Random(7); 
    const count = 18;
    final travel = size.height * 1.4;
    for (var i = 0; i < count; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;
      final speedFactor = 0.5 + rnd.nextDouble();
      final radius = 4.0 + rnd.nextDouble() * 10;
      final y = (baseY - progress * travel * speedFactor) % (size.height + 80) - 40;
      canvas.drawCircle(Offset(baseX, y), radius, paint);
      canvas.drawCircle(
        Offset(baseX, y),
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
