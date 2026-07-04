import 'package:flutter/material.dart';

import '../models/session_view.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import 'glass_card.dart';
import 'score_ring.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, this.onDelete});

  final SessionView session;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final workoutColor = colorFromHex(session.workoutColor);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                fmtLong(session.date),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: workoutColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: workoutColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  session.workoutName,
                  style: TextStyle(color: workoutColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              if (session.duration != null)
                Text('⏱ ${session.duration} мин', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              if (session.rpe != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('RPE ${session.rpe}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ScoreRing(value: session.score),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 11),
          for (final e in session.entries) _ExerciseRow(entry: e),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (session.moodEmoji != null) _pill('${session.moodEmoji} ${session.moodLabel}'),
              if (session.fatigue != null)
                _pill('усталость ${session.fatigue}/5', color: colorFromHex(session.fatigueColor!)),
              for (final t in session.tags) _pill('#$t'),
              if (onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: onDelete,
                    child: const Text('удалить', style: TextStyle(color: AppColors.red, fontSize: 12)),
                  ),
                ),
            ],
          ),
          if (session.notes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFF66E0D1), width: 3)),
              ),
              child: Text(
                session.notes,
                style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color ?? AppColors.muted)),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.entry});
  final EntryView entry;

  @override
  Widget build(BuildContext context) {
    final rSets = entry.setsForArm('R');
    final lSets = entry.setsForArm('L');
    final isSec = entry.unit == 'sec';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              entry.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (rSets.isNotEmpty) ...[
                const Text('П ', style: TextStyle(color: AppColors.orangeLight, fontWeight: FontWeight.w700, fontSize: 12.5)),
                Text(
                  rSets.map((s) => '${_fmtNum(s.weight)}×${_fmtNum(s.reps)}').join('  '),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
              if (rSets.isNotEmpty && lSets.isNotEmpty) const Text('   ·   ', style: TextStyle(color: AppColors.muted)),
              if (lSets.isNotEmpty) ...[
                const Text('Л ', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 12.5)),
                Text(
                  lSets.map((s) => '${_fmtNum(s.weight)}×${_fmtNum(s.reps)}').join('  '),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
              if (isSec)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('(сек)', style: TextStyle(fontSize: 11.5, color: AppColors.dim)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
