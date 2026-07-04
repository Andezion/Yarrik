import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/charts/chart_point.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/glass_card.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final detail = provider.compute.exerciseDetail(provider.state, exerciseId);
    final groupColor = colorFromHex(detail.groupColor);
    final isSec = detail.exercise.unit == 'sec';

    final ptsR = [for (final p in detail.strengthProgression) if (p.topR > 0) ChartPoint(p.topR, fmtShort(p.date))];
    final ptsL = [for (final p in detail.strengthProgression) if (p.topL > 0) ChartPoint(p.topL, fmtShort(p.date))];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(detail.exercise.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            provider.meta.groupById(detail.exercise.group)?.name ?? '',
            style: TextStyle(color: groupColor, fontSize: 13),
          ),
          if (isSec)
            const Text(' · статика (сек)', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardTitle('Рабочий вес по тренировкам'),
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
                    LineSeries(points: ptsL, color: AppColors.blue),
                    LineSeries(points: ptsR, color: const Color(0xFF3AAE2F)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'История · ${detail.history.length}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (detail.history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Записей по этому упражнению пока нет.', style: TextStyle(color: AppColors.muted)),
            )
          else
            for (final h in detail.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmtShort(h.date), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            [
                              if (h.topR > 0) 'П ${_fmt(h.topR)}',
                              if (h.topL > 0) 'Л ${_fmt(h.topL)}',
                            ].join(' / '),
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        h.sets.map((s) => '${s.arm == 'R' ? 'П' : 'Л'} ${_fmt(s.weight)}×${_fmt(s.reps)}').join('  ·  '),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                      ),
                      if (h.notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(h.notes, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

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
}
