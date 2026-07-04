import 'catalog.dart';
import 'session_view.dart';
import 'stats_data.dart';

class ExerciseRow {
  const ExerciseRow({
    required this.id,
    required this.name,
    required this.groupId,
    required this.groupColor,
    required this.unit,
    required this.lastDate,
    required this.curR,
    required this.curL,
    required this.volume,
    required this.bestR,
    required this.bestL,
    required this.isPr,
    required this.progressPct,
  });

  final String id;
  final String name;
  final String groupId;
  final String groupColor;
  final String unit;
  final String? lastDate;
  final double curR;
  final double curL;
  final double volume;
  final double bestR;
  final double bestL;
  final bool isPr;
  final int? progressPct;

  factory ExerciseRow.fromJson(Map<String, dynamic> j) => ExerciseRow(
        id: j['id'] as String,
        name: j['name'] as String,
        groupId: j['groupId'] as String,
        groupColor: (j['groupColor'] as String?) ?? '#1E7FD6',
        unit: j['unit'] as String,
        lastDate: j['lastDate'] as String?,
        curR: (j['curR'] as num).toDouble(),
        curL: (j['curL'] as num).toDouble(),
        volume: (j['volume'] as num).toDouble(),
        bestR: (j['bestR'] as num).toDouble(),
        bestL: (j['bestL'] as num).toDouble(),
        isPr: (j['isPr'] as bool?) ?? false,
        progressPct: j['progressPct'] as int?,
      );
}

class ExerciseHistoryItem {
  const ExerciseHistoryItem({
    required this.date,
    required this.sets,
    required this.notes,
    required this.topR,
    required this.topL,
  });

  final String date;
  final List<SetView> sets;
  final String notes;
  final double topR;
  final double topL;

  factory ExerciseHistoryItem.fromJson(Map<String, dynamic> j) => ExerciseHistoryItem(
        date: j['date'] as String,
        sets: (j['sets'] as List)
            .map((e) => SetView.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: (j['notes'] as String?) ?? '',
        topR: (j['topR'] as num).toDouble(),
        topL: (j['topL'] as num).toDouble(),
      );
}

class ExerciseDetail {
  const ExerciseDetail({
    required this.exercise,
    required this.groupColor,
    required this.strengthProgression,
    required this.history,
  });

  final ExerciseDef exercise;
  final String groupColor;
  final List<StrengthPoint> strengthProgression;
  final List<ExerciseHistoryItem> history;

  factory ExerciseDetail.fromJson(Map<String, dynamic> j) => ExerciseDetail(
        exercise: ExerciseDef.fromJson(j['exercise'] as Map<String, dynamic>),
        groupColor: (j['groupColor'] as String?) ?? '#1E7FD6',
        strengthProgression: (j['strengthProgression'] as List)
            .map((e) => StrengthPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        history: (j['history'] as List)
            .map((e) => ExerciseHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
