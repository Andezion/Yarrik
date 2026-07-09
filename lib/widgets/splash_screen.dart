import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1450A8), Color(0xFF2E7FD2), Color(0xFF79BCEA), Color(0xFFD6EEFA)],
          stops: [0, 0.42, 0.72, 1],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.55),
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    const Color(0xFFA0EBFF).withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 0.72],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Opacity(
                  opacity: 1 - (_pulse.value * 0.35),
                  child: child,
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: const Color(0xFFF4FBFF),
                      shadows: [
                        Shadow(color: Colors.blue.shade900.withValues(alpha: 0.55), blurRadius: 4, offset: const Offset(0, 2)),
                        Shadow(color: AppColors.sky.withValues(alpha: 0.75), blurRadius: 26),
                      ],
                    ),
                    children: const [
                      TextSpan(text: 'ARM'),
                      TextSpan(
                        text: 'FORGE',
                        style: TextStyle(color: AppColors.mint),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 190,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border.all(color: const Color(0xFF94CDE8).withValues(alpha: 0.8)),
                  ),
                  child: AnimatedBuilder(
                    animation: _slide,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment(-1 + _slide.value * 2.7, 0),
                        child: FractionallySizedBox(
                          widthFactor: 0.44,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9FECFF), AppColors.aqua, Color(0xFF12B0E6), Color(0xFF54D6F8)],
                                stops: [0, 0.5, 0.52, 1],
                              ),
                              boxShadow: [
                                BoxShadow(color: AppColors.aqua.withValues(alpha: 0.7), blurRadius: 12),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
