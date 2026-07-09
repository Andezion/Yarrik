import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_data.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/aero_button.dart';
import '../widgets/aero_sheet.dart';
import '../widgets/glass_card.dart';
import '../widgets/session_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _year;
  late int _month; 

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _shift(int delta) {
    setState(() {
      var m = _month + delta;
      var y = _year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      _month = m;
      _year = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final meta = provider.meta;
    final data = provider.compute.calendar(provider.state, _year, _month);
    final byDate = {for (final d in data.days) d.date: d};

    final first = DateTime(_year, _month, 1);
    final startDow = (first.weekday - 1) % 7; 
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final today = todayIso();

    return ListView(
      children: [
        Text('Календарь', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          'Каждый тренировочный день подсвечен цветом тренировки',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${monFull[_month - 1]} $_year',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.headingColor),
                  ),
                  Row(
                    children: [
                      AeroIconButton(icon: Icons.chevron_left, onTap: () => _shift(-1)),
                      const SizedBox(width: 8),
                      AeroIconButton(icon: Icons.chevron_right, onTap: () => _shift(1)),
                    ],
                  ),
                ],
              ),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.92,
                children: [
                  for (final d in dowShort)
                    Center(
                      child: Text(d, style: const TextStyle(fontSize: 10.5, color: AppColors.dim)),
                    ),
                  for (var i = 0; i < startDow; i++) const SizedBox.shrink(),
                  for (var day = 1; day <= daysInMonth; day++)
                    _DayCell(
                      day: day,
                      isToday: _iso(_year, _month, day) == today,
                      calDay: byDate[_iso(_year, _month, day)],
                      onTap: byDate.containsKey(_iso(_year, _month, day))
                          ? () => _openDay(context, _iso(_year, _month, day))
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  for (final w in meta.workouts)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: colorFromHex(w.color), shape: BoxShape.circle),
                        ),
                        Text(w.name, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  String _iso(int y, int m, int d) => '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  void _openDay(BuildContext context, String date) {
    final provider = context.read<AppStateProvider>();
    final sessions = provider.compute.sessionsOnDate(provider.state, date);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, controller) => Container(
          decoration: aeroSheetDecoration(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: ListView(
            controller: controller,
            children: [
              const SheetHandle(),
              SheetHeader(title: fmtLong(date)),
              const SizedBox(height: 12),
              for (final s in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SessionCard(session: s),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, required this.calDay, this.onTap});

  final int day;
  final bool isToday;
  final CalendarDay? calDay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSessions = calDay != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: hasSessions ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: isToday ? AppColors.aqua : Colors.white.withValues(alpha: 0.6),
            width: isToday ? 2.4 : 1,
          ),
          boxShadow: [
            if (isToday) BoxShadow(color: AppColors.aqua.withValues(alpha: 0.4), blurRadius: 12),
            if (hasSessions && !isToday)
              BoxShadow(color: AppColors.blueDark.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$day', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const Spacer(),
            if (hasSessions)
              Wrap(
                spacing: 3,
                children: [
                  for (final c in calDay!.workoutColors)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: colorFromHex(c), shape: BoxShape.circle),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
