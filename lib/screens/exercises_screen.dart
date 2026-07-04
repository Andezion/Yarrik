import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise_row.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/glass_card.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final rows = provider.compute.exercisesTable(provider.state);

    return ListView(
      children: [
        Text('Упражнения', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          '15 движений · рекорды и прогресс за 4 недели · тап — история',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExerciseRowTile(
              row: row,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exerciseId: row.id)),
              ),
            ),
          ),
        const SizedBox(height: 90),
      ],
    );
  }
}

class _ExerciseRowTile extends StatelessWidget {
  const _ExerciseRowTile({required this.row, required this.onTap});

  final ExerciseRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final groupColor = colorFromHex(row.groupColor);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    Text(
                      row.lastDate != null ? 'посл. ${fmtShort(row.lastDate!)}' : 'нет записей',
                      style: TextStyle(color: groupColor, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (row.curR > 0 || row.curL > 0)
                Text(
                  [
                    if (row.curR > 0) 'П ${_fmt(row.curR)}',
                    if (row.curL > 0) 'Л ${_fmt(row.curL)}',
                  ].join(' / '),
                  style: const TextStyle(fontSize: 12.5),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Рекорд: ${row.bestR > 0 ? _fmt(row.bestR) : '—'} / ${row.bestL > 0 ? _fmt(row.bestL) : '—'} кг',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              if (row.isPr)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold)),
                ),
              _progressBadge(row.progressPct),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Widget _progressBadge(int? pct) {
    if (pct == null) {
      return _badge('нет базы', AppColors.muted);
    }
    if (pct > 0) return _badge('▲ +$pct%', AppColors.green);
    if (pct < 0) return _badge('▼ $pct%', AppColors.red);
    return _badge('0%', AppColors.muted);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
