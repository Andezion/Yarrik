import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class EmptyChart extends StatelessWidget {
  const EmptyChart({super.key, this.height = 200, this.message = 'Нет данных для графика.'});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF5A9BD2).withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
        color: Colors.white.withValues(alpha: 0.4),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    );
  }
}
