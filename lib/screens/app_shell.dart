import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/nav_items.dart';
import '../utils/tab_switcher.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'diary_screen.dart';
import 'exercises_screen.dart';
import 'goals_screen.dart';
import 'log_workout_sheet.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.dash;

  Widget _screenFor(AppTab tab) {
    switch (tab) {
      case AppTab.dash:
        return const DashboardScreen();
      case AppTab.diary:
        return const DiaryScreen();
      case AppTab.cal:
        return const CalendarScreen();
      case AppTab.stats:
        return const StatisticsScreen();
      case AppTab.ex:
        return const ExercisesScreen();
      case AppTab.goals:
        return const GoalsScreen();
      case AppTab.set:
        return const SettingsScreen();
    }
  }

  void _go(AppTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 920;

    return TabSwitcher(
      go: _go,
      child: _buildScaffold(context, wide),
    );
  }

  Widget _buildScaffold(BuildContext context, bool wide) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          if (wide) _Sidebar(current: _tab, onSelect: _go),
          Expanded(
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: _screenFor(_tab),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 22,
                    child: _AeroFab(onPressed: () => openLogWorkoutSheet(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide ? null : _BottomNav(current: _tab, onSelect: _go),
    );
  }
}

class _NavOrb extends StatelessWidget {
  const _NavOrb({required this.icon, required this.color, this.selected = false, this.size = 27});

  final IconData icon;
  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.48),
          colors: [Colors.white.withValues(alpha: 0.96), Colors.white.withValues(alpha: 0.4), color],
          stops: const [0, 0.26, 0.62],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 5, offset: const Offset(0, 3)),
          if (selected) BoxShadow(color: Colors.white.withValues(alpha: 0.75), blurRadius: 10),
        ],
      ),
      child: Icon(icon, size: size * 0.52, color: Colors.white),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.current, required this.onSelect});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AppStateProvider, String>((p) => p.state.name);

    return Container(
      width: 226,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.78), const Color(0xFFEBFAFF).withValues(alpha: 0.6)],
        ),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.9))),
        boxShadow: [BoxShadow(color: AppColors.aquaDeep.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(6, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.text,
                ),
                children: [
                  const TextSpan(text: 'ARM'),
                  TextSpan(
                    text: 'FORGE',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = const LinearGradient(colors: [AppColors.aquaDeep, Color(0xFF2EC9F2), AppColors.green])
                            .createShader(const Rect.fromLTWH(0, 0, 120, 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final item in navItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _NavButton(
                item: item,
                selected: item.tab == current,
                onTap: () => onSelect(item.tab),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Категория 87 кг\nСезон 2026 · $name',
              style: TextStyle(fontSize: 11, color: AppColors.dim, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orbColor = AppColors.navOrb(item.tab.name);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF2EC3EF), Color(0xFF3BCBBB), Color(0xFF54C74A)],
                  )
                : null,
            border: selected ? Border.all(color: Colors.white.withValues(alpha: 0.6)) : null,
            boxShadow: selected
                ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              _NavOrb(icon: item.icon, color: orbColor, selected: selected),
              const SizedBox(width: 11),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.muted,
                  shadows: selected ? [Shadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 2)] : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onSelect});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.9), const Color(0xFFECFAFF).withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(color: AppColors.aquaDeep.withValues(alpha: 0.24), blurRadius: 26, offset: const Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (final tab in mobileNavTabs)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onSelect(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavOrb(
                          icon: navItems.firstWhere((n) => n.tab == tab).icon,
                          color: AppColors.navOrb(tab.name),
                          selected: tab == current,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mobileNavLabels[tab]!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tab == current ? AppColors.aquaText : AppColors.dim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AeroFab extends StatefulWidget {
  const _AeroFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AeroFab> createState() => _AeroFabState();
}

class _AeroFabState extends State<_AeroFab> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final glowAmt = _glow.value;
        return GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _down ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.32, -0.34),
                  colors: [Color(0xFFCFF7FF), Color(0xFF7FE3FF), Color(0xFF22C0EE), Color(0xFF0A7CB0)],
                  stops: [0, 0.22, 0.55, 1],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aquaDeep.withValues(alpha: 0.45 + glowAmt * 0.15),
                    blurRadius: 22 + glowAmt * 12,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.aqua.withValues(alpha: 0.35 + glowAmt * 0.35),
                    blurRadius: 16 + glowAmt * 18,
                  ),
                ],
              ),
              child: Icon(Icons.add, size: 30, color: Colors.white.withValues(alpha: 0.98)),
            ),
          ),
        );
      },
    );
  }
}
