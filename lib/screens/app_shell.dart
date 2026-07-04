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
                    child: FloatingActionButton(
                      heroTag: 'fab-log',
                      backgroundColor: AppColors.blue,
                      onPressed: () => openLogWorkoutSheet(context),
                      child: const Icon(Icons.add, size: 28),
                    ),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.current, required this.onSelect});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AppStateProvider, String>((p) => p.state.name);

    return Container(
      width: 224,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.78), const Color(0xFFEBFAFF).withValues(alpha: 0.6)],
        ),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFF1F4568),
                ),
                children: [
                  TextSpan(text: 'ARM'),
                  TextSpan(text: 'FORGE', style: TextStyle(color: AppColors.teal)),
                ],
              ),
            ),
          ),
          for (final item in navItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withValues(alpha: 0.98), const Color(0xFFA0DAFF).withValues(alpha: 0.9)],
                  )
                : null,
            border: selected ? Border.all(color: Colors.white.withValues(alpha: 0.95)) : null,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: selected ? AppColors.blue : AppColors.muted),
              const SizedBox(width: 11),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF0E5EA8) : AppColors.muted,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.95))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final tab in mobileNavTabs)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          navItems.firstWhere((n) => n.tab == tab).icon,
                          size: 20,
                          color: tab == current ? AppColors.blue : AppColors.dim,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mobileNavLabels[tab]!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: tab == current ? AppColors.blue : AppColors.dim,
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
