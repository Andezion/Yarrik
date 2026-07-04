import 'package:flutter/material.dart';

enum AppTab { dash, diary, cal, stats, ex, goals, set }

class NavItem {
  const NavItem(this.tab, this.label, this.icon);
  final AppTab tab;
  final String label;
  final IconData icon;
}

const navItems = [
  NavItem(AppTab.dash, 'Дашборд', Icons.space_dashboard_rounded),
  NavItem(AppTab.diary, 'Дневник', Icons.menu_book_rounded),
  NavItem(AppTab.cal, 'Календарь', Icons.calendar_month_rounded),
  NavItem(AppTab.stats, 'Статистика', Icons.bar_chart_rounded),
  NavItem(AppTab.ex, 'Упражнения', Icons.fitness_center_rounded),
  NavItem(AppTab.goals, 'Цели', Icons.track_changes_rounded),
  NavItem(AppTab.set, 'Настройки', Icons.settings_rounded),
];

const mobileNavTabs = [AppTab.dash, AppTab.diary, AppTab.cal, AppTab.stats, AppTab.set];

const mobileNavLabels = {
  AppTab.dash: 'Дашборд',
  AppTab.diary: 'Дневник',
  AppTab.cal: 'Календарь',
  AppTab.stats: 'Стата',
  AppTab.set: 'Ещё',
};
