import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stats_data.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/chart_point.dart';
import '../widgets/charts/donut_chart_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/glass_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final meta = provider.meta;
    final exerciseId = _selectedExerciseId ?? meta.exercises.first.id;
    final data = provider.compute.stats(provider.state, exerciseId);
    final wide = MediaQuery.sizeOf(context).width > 920;

    final weekPoints = [for (final w in data.weeklyTonnage) ChartPoint(w.volume, fmtShort(w.weekStart))];
    final monthPoints = [for (final m in data.monthlyTonnage) ChartPoint(m.volume, monShort[int.parse(m.month.split('-')[1]) - 1])];
    final strengthR = [for (final p in data.strengthProgression) if (p.topR > 0) ChartPoint(p.topR, fmtShort(p.date))];
    final strengthL = [for (final p in data.strengthProgression) if (p.topL > 0) ChartPoint(p.topL, fmtShort(p.date))];
    final fatiguePoints = [for (final f in data.fatigueTrend) ChartPoint(f.fatigue.toDouble(), fmtShort(f.date))];

    return ListView(
      children: [
        Text('Статистика', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          'Объёмы, сила и восстановление в динамике',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        wide
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CardTitle('Тоннаж по неделям · 12 нед.'),
                            BarChartWidget(points: weekPoints, formatY: fmtVol),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CardTitle('Тоннаж по месяцам'),
                            BarChartWidget(
                              points: monthPoints,
                              colorTop: const Color(0xFF7ED957),
                              colorBottom: const Color(0xFF2E9825),
                              formatY: fmtVol,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CardTitle('Тоннаж по неделям · 12 нед.'),
                        BarChartWidget(points: weekPoints, formatY: fmtVol),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CardTitle('Тоннаж по месяцам'),
                        BarChartWidget(
                          points: monthPoints,
                          colorTop: const Color(0xFF7ED957),
                          colorBottom: const Color(0xFF2E9825),
                          formatY: fmtVol,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CardTitle('Прогресс силы · лучший вес за тренировку'),
              DropdownButtonFormField<String>(
                value: exerciseId,
                isExpanded: true,
                items: [
                  for (final ex in meta.exercises) DropdownMenuItem(value: ex.id, child: Text(ex.name)),
                ],
                onChanged: (v) => setState(() => _selectedExerciseId = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _legendDot(const Color(0xFF3AAE2F), 'правая'),
                  const SizedBox(width: 14),
                  _legendDot(AppColors.blue, 'левая'),
                ],
              ),
              const SizedBox(height: 8),
              LineChartWidget(
                height: 230,
                series: [
                  LineSeries(points: strengthL, color: AppColors.blue),
                  LineSeries(points: strengthR, color: const Color(0xFF3AAE2F)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        wide
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _fatigueCard(fatiguePoints)),
                    const SizedBox(width: 16),
                    Expanded(child: _distributionCard(data.groupDistribution)),
                  ],
                ),
              )
            : Column(
                children: [
                  _fatigueCard(fatiguePoints),
                  const SizedBox(height: 16),
                  _distributionCard(data.groupDistribution),
                ],
              ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      ],
    );
  }

  Widget _fatigueCard(List<ChartPoint> points) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Тренд усталости · 1 свежий — 5 разбит'),
          LineChartWidget(
            series: [LineSeries(points: points, color: const Color(0xFFF2A93B), area: true)],
            lo: 0,
            hi: 5,
            formatY: (v) => v.round().toString(),
          ),
        ],
      ),
    );
  }

  Widget _distributionCard(List<GroupSlice> distribution) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Распределение по группам'),
          DonutChartWidget(
            slices: [
              for (final g in distribution)
                DonutSlice(label: g.name, value: g.count, color: colorFromHex(g.color)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Доля подходов на каждую группу за всё время. Держи крюк/бок ведущими, но не забывай пронацию.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
