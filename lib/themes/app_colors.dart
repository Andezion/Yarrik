import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFFDFF3FF);
  static const line = Color(0x385896CD); 
  static const line2 = Color(0x614687C3); 
  static const text = Color(0xFF2B3A4A);
  static const muted = Color(0xFF5E7387);
  static const dim = Color(0xFF7E95AA);

  static const blue = Color(0xFF1E7FD6);
  static const blueDark = Color(0xFF1668B8);
  static const aqua = Color(0xFF5CB8FF);
  static const teal = Color(0xFF17B8A6);

  static const orange = Color(0xFF38B24A); 
  static const orangeLight = Color(0xFF1F8F35);

  static const gold = Color(0xFFA9720E);
  static const green = Color(0xFF1FA84D);
  static const red = Color(0xFFD6453D);

  static const skyGradient = [
    Color(0xFFEAF8FF),
    Color(0xFFBCE4FF), 
    Color(0xFFA9E4EF), 
    Color(0xFFC4F0CE), 
  ];
  static const skyGradientStops = [0.0, 0.34, 0.64, 1.0];

  static const glassGradient = [
    Color(0xE6FFFFFF), 
    Color(0x8CFFFFFF), 
    Color(0x9EDEF5FF), 
  ];
  static const glassGradientStops = [0.0, 0.46, 1.0];

  static const workoutColors = [
    Color(0xFF2E97E5),
    Color(0xFF17B8A6),
    Color(0xFFF2A93B),
    Color(0xFF57C84D),
    Color(0xFF9A7BE8),
  ];

  static const groupColors = <String, Color>{
    'bok': Color(0xFF17B8A6),
    'kist': Color(0xFF2E97E5),
    'verh': Color(0xFFF2A93B),
    'baza': Color(0xFF57C84D),
  };

  static const fatigueColors = [
    Color(0xFF57C84D),
    Color(0xFF8CC63F),
    Color(0xFFF2A93B),
    Color(0xFFF5822E),
    Color(0xFFE8564E),
  ];

  static Color scoreColor(int v) {
    if (v >= 85) return const Color(0xFF2FA344);
    if (v >= 70) return const Color(0xFFF2A93B);
    if (v >= 55) return const Color(0xFFF5822E);
    return const Color(0xFFE8564E);
  }

  static Color workoutColor(int idx) =>
      workoutColors[idx % workoutColors.length];

  static Color groupColor(String groupId) =>
      groupColors[groupId] ?? blue;

  static Color fatigueColor(int fatigue1to5) =>
      fatigueColors[(fatigue1to5 - 1).clamp(0, fatigueColors.length - 1)];
}
