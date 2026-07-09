import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_data.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../utils/nav_items.dart';
import '../utils/tab_switcher.dart';
import '../widgets/aero_button.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/chart_point.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/score_ring.dart';
import 'log_workout_sheet.dart';

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 5) return 'Доброй ночи';
  if (hour < 12) return 'Доброе утро';
  if (hour < 18) return 'Добрый день';
  return 'Добрый вечер';
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final data = provider.compute.dashboard(provider.state);
    final wide = MediaQuery.sizeOf(context).width > 920;

    return ListView(
      children: [
        _HeroCard(data: data),
        const SizedBox(height: 16),
        wide
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _PrCard(data: data)),
                    const SizedBox(width: 16),
                    Expanded(child: _RecoveryCard(data: data)),
                    const SizedBox(width: 16),
                    Expanded(child: _BodyweightCard(data: data)),
                  ],
                ),
              )
            : Column(
                children: [
                  _PrCard(data: data),
                  const SizedBox(height: 16),
                  _RecoveryCard(data: data),
                  const SizedBox(height: 16),
                  _BodyweightCard(data: data),
                ],
              ),
        const SizedBox(height: 16),
        wide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _WeeklyTonnageCard(data: data)),
                    const SizedBox(width: 16),
                    Expanded(child: _RecentSessionsCard(data: data)),
                  ],
                ),
              )
            : Column(
                children: [
                  _WeeklyTonnageCard(data: data),
                  const SizedBox(height: 16),
                  _RecentSessionsCard(data: data),
                ],
              ),
        const SizedBox(height: 90),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pctL = data.armBalance.pctL;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${data.name}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.headingColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${now.day} ${monShort[now.month - 1]} · следующая по кругу — ${data.nextWorkoutName.toLowerCase()}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (data.daysToTourney != null) _TourneyChip(days: data.daysToTourney!),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 34,
            runSpacing: 12,
            children: [
              _HeroStat(value: '${data.weekSessionsCount}', label: 'тренировок за неделю'),
              _HeroStat(value: fmtVol(data.weekVolume), label: 'тоннаж недели'),
              _HeroStat(value: '${data.weekSets}', label: 'подходов'),
              _HeroStat(value: '${data.streakWeeks} нед.', label: 'серия без пропусков'),
            ],
          ),
          const SizedBox(height: 20),
          const CardTitle('Баланс рук · сумма лучших весов'),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: 100 - pctL,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.orange, Color(0xFFFFB25C)]),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: pctL,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.aquaDeep, AppColors.aqua]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(TextSpan(
                style: const TextStyle(color: AppColors.orangeLight, fontSize: 11.5),
                children: [
                  TextSpan(
                    text: '${data.armBalance.sumR.round()} ',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const TextSpan(text: 'кг · правая'),
                ],
              )),
              Text.rich(TextSpan(
                style: const TextStyle(color: AppColors.blue, fontSize: 11.5),
                children: [
                  const TextSpan(text: 'левая · '),
                  TextSpan(
                    text: '${data.armBalance.sumL.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const TextSpan(text: ' кг'),
                ],
              )),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AeroButton(
                label: 'Записать тренировку',
                icon: Icons.add,
                onPressed: () => openLogWorkoutSheet(context),
              ),
              AeroButton(
                label: 'Открыть дневник',
                variant: AeroButtonVariant.ghost,
                onPressed: () => TabSwitcher.of(context).go(AppTab.diary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourneyChip extends StatelessWidget {
  const _TourneyChip({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.9), const Color(0xFFFFE6D5).withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.55)),
        boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: AppColors.orangeLight, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.orangeLight.withValues(alpha: 0.7), blurRadius: 5)]),
          ),
          const SizedBox(width: 7),
          Text(
            'До турнира $days дн.',
            style: const TextStyle(
              color: AppColors.orangeLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.headingColor)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.4)),
      ],
    );
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            'Личные рекорды',
            trailing: GestureDetector(
              onTap: () => TabSwitcher.of(context).go(AppTab.ex),
              child: const Text('все →',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          if (data.recentPrs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Рекордов пока нет — они появятся после первых записей.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            for (final pr in data.recentPrs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('PR',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pr.exerciseName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                          Text(
                            '${fmtShort(pr.date)} · ${pr.arm == 'R' ? 'правая' : 'левая'}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${pr.weight} кг',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: pr.arm == 'R' ? AppColors.orangeLight : AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Восстановление групп'),
          for (final r in data.recovery)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(r.name, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(
                          value: r.pct / 100,
                          backgroundColor: const Color(0xFF3C82BE).withValues(alpha: 0.14),
                          color: _recoveryColor(r.pct),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${r.pct}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: _recoveryColor(r.pct), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Свежесть по дням с последней нагрузки группы.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _recoveryColor(int pct) {
    if (pct >= 80) return AppColors.green;
    if (pct >= 45) return AppColors.gold;
    return AppColors.orange;
  }
}

class _BodyweightCard extends StatelessWidget {
  const _BodyweightCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final sorted = [...data.bodyweight]..sort((a, b) => a.date.compareTo(b.date));
    final points = [for (final b in sorted) ChartPoint(b.kg, fmtShort(b.date))];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Вес тела'),
          if (points.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Добавь замеры веса в настройках.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            )
          else
            LineChartWidget(
              series: [LineSeries(points: points, color: AppColors.blue, area: true)],
              height: 190,
              refLine: 87,
              refLabel: '87 кг — категория',
              formatY: (v) => v.round().toString(),
            ),
        ],
      ),
    );
  }
}

class _WeeklyTonnageCard extends StatelessWidget {
  const _WeeklyTonnageCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final points = [for (final w in data.weeklyTonnage) ChartPoint(w.volume, fmtShort(w.weekStart))];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Тоннаж по неделям'),
          BarChartWidget(
            points: points,
            colorTop: const Color(0xFFFFB25C),
            colorBottom: AppColors.orange,
            formatY: (v) => fmtVol(v),
          ),
        ],
      ),
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            'Последние тренировки',
            trailing: GestureDetector(
              onTap: () => TabSwitcher.of(context).go(AppTab.diary),
              child: const Text('дневник →',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          if (data.recentSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Пока нет тренировок.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            )
          else
            for (final s in data.recentSessions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(fmtShort(s.date), style: const TextStyle(fontSize: 12.5)),
                              const Text(' · ', style: TextStyle(color: AppColors.muted)),
                              Text(
                                s.workoutName,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colorFromHex(s.workoutColor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${s.entries.length} упр. · ${s.setsCount} подходов'
                            '${s.duration != null ? ' · ${s.duration} мин' : ''}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    ScoreRing(value: s.score),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
