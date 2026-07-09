import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFFDFF4FD);
  static const line = Color(0x24157AAA);
  static const line2 = Color(0x42157AAA);
  static const text = Color(0xFF2C4A5E);
  static const muted = Color(0xFF54798E);
  static const dim = Color(0xFF7C9DB0);

  static const aqua = Color(0xFF38D6FF);
  static const mint = Color(0xFF64F5E8);
  static const sky = Color(0xFF5BC8FF);
  static const aquaDeep = Color(0xFF0FA8DE);
  static const aquaText = Color(0xFF0883B8);

  static const blue = Color(0xFF0F7FD0);
  static const blueDark = Color(0xFF0A67AE);
  static const teal = Color(0xFF17B8A6);

  static const orange = Color(0xFFF07816);
  static const orangeLight = Color(0xFFE06A00);

  static const gold = Color(0xFFDE9C0A);
  static const green = Color(0xFF3BAF1E);
  static const red = Color(0xFFE14B38);

  static const skyGradient = [
    Color(0xFF1450A8),
    Color(0xFF2E7FD2),
    Color(0xFF79BCEA),
    Color(0xFFD6EEFA),
    Color(0xFFEAF7FD),
  ];
  static const skyGradientStops = [0.0, 0.28, 0.62, 0.88, 1.0];

  static const glassGradient = [
    Color(0xC2FFFFFF),
    Color(0x52FFFFFF),
    Color(0x70D6F8FF),
  ];
  static const glassGradientStops = [0.0, 0.46, 1.0];

  static const workoutColors = [
    Color(0xFFFF8A24),
    Color(0xFF1E9BE9),
    Color(0xFFEFAF1B),
    Color(0xFF52BD3A),
    Color(0xFF9D6FE8),
  ];

  static const groupColors = <String, Color>{
    'bok': Color(0xFFFF8A24),
    'kist': Color(0xFF1E9BE9),
    'verh': Color(0xFFEFAF1B),
    'baza': Color(0xFF52BD3A),
  };

  static const fatigueColors = [
    Color(0xFF52BD3A),
    Color(0xFF9CC122),
    Color(0xFFEFAF1B),
    Color(0xFFFF8A24),
    Color(0xFFF0523F),
  ];

  // per-tab accent used for the sidebar/bottom-nav "orb" icons
  static const navOrbColors = <String, Color>{
    'dash': Color(0xFF1FB6F0),
    'diary': Color(0xFFFF8A24),
    'cal': Color(0xFF52BD3A),
    'stats': Color(0xFF9D6FE8),
    'ex': Color(0xFF3E8ADB),
    'goals': Color(0xFFF5B70A),
    'set': Color(0xFF8AA5B8),
  };

  static Color scoreColor(int v) {
    if (v >= 85) return green;
    if (v >= 70) return gold;
    if (v >= 55) return orange;
    return red;
  }

  static Color workoutColor(int idx) =>
      workoutColors[idx % workoutColors.length];

  static Color groupColor(String groupId) =>
      groupColors[groupId] ?? blue;

  static Color fatigueColor(int fatigue1to5) =>
      fatigueColors[(fatigue1to5 - 1).clamp(0, fatigueColors.length - 1)];

  static Color navOrb(String tabKey) => navOrbColors[tabKey] ?? blue;
}
