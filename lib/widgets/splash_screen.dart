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
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
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
          colors: [Color(0xFFEAF8FF), Color(0xFFBCE4FF), Color(0xFFB7EDDD)],
          stops: [0, 0.6, 1],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Opacity(
                opacity: 1 - (_pulse.value * 0.45),
                child: child,
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: Color(0xFF1F4568),
                  ),
                  children: [
                    TextSpan(text: 'ARM'),
                    TextSpan(
                      text: 'FORGE',
                      style: TextStyle(color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: 160,
                height: 5,
                color: Colors.white.withValues(alpha: 0.7),
                child: AnimatedBuilder(
                  animation: _slide,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment(-1 + _slide.value * 2.7, 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF9FE3FF), Color(0xFF1E8FE0)],
                            ),
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
      ),
    );
  }
}
