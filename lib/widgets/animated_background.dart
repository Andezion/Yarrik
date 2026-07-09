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
      duration: const Duration(seconds: 40),
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
              painter: _SunFlarePainter(t: _controller.value),
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _SparklesPainter(t: _controller.value),
            ),
          ),
        ),
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
        AppColors.mint.withValues(alpha: 0.28));
    radial(Offset(size.width * 0.06, size.height * 1.06), size.width * 0.5,
        const Color(0xFF8EEA8A).withValues(alpha: 0.3));
    radial(Offset(size.width * 0.96, size.height * 1.05), size.width * 0.5,
        const Color(0xFF8EEA8A).withValues(alpha: 0.22));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunFlarePainter extends CustomPainter {
  _SunFlarePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.16, size.height * 0.045);

    final rayAngle = math.sin(t * 2 * math.pi) * 0.035;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rayAngle);
    final rayPaint = Paint()..blendMode = BlendMode.plus;
    const rayCount = 5;
    for (var i = 0; i < rayCount; i++) {
      final a = (i / rayCount) * math.pi * 2 + 0.3;
      final len = size.width * 0.55;
      final width = size.width * 0.09;
      final end = Offset(math.cos(a) * len, math.sin(a) * len * 0.6);
      rayPaint.shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromPoints(Offset.zero, end));
      final path = Path()
        ..moveTo(-width * 0.1, -width * 0.1)
        ..lineTo(end.dx, end.dy - width / 2)
        ..lineTo(end.dx, end.dy + width / 2)
        ..lineTo(width * 0.1, width * 0.1)
        ..close();
      canvas.drawPath(path, rayPaint);
    }
    canvas.restore();

    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 1.4);
    final coreRadius = size.width * (0.05 + 0.006 * pulse);
    final glowRadius = size.width * 0.16;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.55 + 0.15 * pulse),
          const Color(0xFFAAE6FF).withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: origin, radius: glowRadius));
    canvas.drawCircle(origin, glowRadius, glowPaint);

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, const Color(0xFFEFFDFF), const Color(0xFFBDEBFF).withValues(alpha: 0)],
        stops: const [0, 0.4, 1],
      ).createShader(Rect.fromCircle(center: origin, radius: coreRadius));
    canvas.drawCircle(origin, coreRadius, corePaint);

    final chainOffsets = [0.16, 0.23, 0.30, 0.37, 0.44];
    for (var i = 0; i < chainOffsets.length; i++) {
      final f = chainOffsets[i];
      final c = Offset(origin.dx + size.width * f * 1.1, origin.dy + size.height * f * 0.6);
      final r = size.width * (0.012 - i * 0.0015);
      final alpha = (0.5 - i * 0.09).clamp(0.05, 1.0);
      canvas.drawCircle(
        c,
        r.clamp(1.0, 20.0),
        Paint()
          ..shader = RadialGradient(colors: [Colors.white.withValues(alpha: alpha), Colors.white.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: c, radius: r.clamp(1.0, 20.0))),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunFlarePainter oldDelegate) => oldDelegate.t != t;
}

class _SparklesPainter extends CustomPainter {
  _SparklesPainter({required this.t});

  final double t;

  static const _positions = [
    Offset(0.34, 0.09),
    Offset(0.53, 0.16),
    Offset(0.72, 0.06),
    Offset(0.12, 0.27),
    Offset(0.64, 0.31),
    Offset(0.85, 0.21),
    Offset(0.45, 0.04),
  ];
  static const _periods = [3.6, 4.4, 5.0, 4.8, 3.2, 5.6, 4.0];
  static const _phases = [0.0, 0.3, 0.55, 0.75, 0.15, 0.42, 0.68];
  static const _sizes = [9.0, 6.5, 8.0, 6.0, 7.0, 7.5, 5.5];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _positions.length; i++) {
      final period = _periods[i];
      final phase = _phases[i];
      final cycle = ((t * 40 / period) + phase) % 1.0;
      final wave = 0.5 - 0.5 * math.cos(cycle * 2 * math.pi);
      final opacity = 0.15 + wave * 0.85;
      final scale = 0.6 + wave * 0.5;
      final pos = Offset(_positions[i].dx * size.width, _positions[i].dy * size.height);
      final r = _sizes[i] * scale;

      final glow = Paint()
        ..shader = RadialGradient(colors: [Colors.white.withValues(alpha: opacity * 0.9), Colors.white.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: pos, radius: r));
      canvas.drawCircle(pos, r, glow);

      final starPaint = Paint()..color = Colors.white.withValues(alpha: opacity);
      final path = Path();
      final rot = cycle * 2 * math.pi * 0.15;
      for (var k = 0; k < 4; k++) {
        final a = rot + k * math.pi / 2;
        final tip = pos + Offset(math.cos(a), math.sin(a)) * r;
        final side1 = pos + Offset(math.cos(a + 0.35), math.sin(a + 0.35)) * (r * 0.16);
        final side2 = pos + Offset(math.cos(a - 0.35), math.sin(a - 0.35)) * (r * 0.16);
        if (k == 0) path.moveTo(tip.dx, tip.dy);
        path.lineTo(side1.dx, side1.dy);
        path.lineTo(tip.dx, tip.dy);
        path.lineTo(side2.dx, side2.dy);
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => oldDelegate.t != t;
}

class _BubblesPainter extends CustomPainter {
  _BubblesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    const count = 14;
    final travel = size.height * 1.4;
    for (var i = 0; i < count; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;
      final speedFactor = 0.5 + rnd.nextDouble();
      final radius = 5.0 + rnd.nextDouble() * 12;
      final drift = math.sin((baseX + progress * 200) * 0.02) * 14;
      final y = (baseY - progress * travel * speedFactor) % (size.height + 80) - 40;
      final center = Offset(baseX + drift, y);

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.3),
            colors: [
              Colors.white.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.12),
              AppColors.sky.withValues(alpha: 0.05),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
