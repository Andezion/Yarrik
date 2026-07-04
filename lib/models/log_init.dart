class LogExercise {
  const LogExercise({
    required this.exId,
    required this.name,
    required this.unit,
    required this.bestR,
    required this.bestL,
    required this.lastWeightR,
    required this.lastWeightL,
  });

  final String exId;
  final String name;
  final String unit;
  final double bestR;
  final double bestL;
  final double lastWeightR;
  final double lastWeightL;

  factory LogExercise.fromJson(Map<String, dynamic> j) => LogExercise(
        exId: j['exId'] as String,
        name: j['name'] as String,
        unit: j['unit'] as String,
        bestR: (j['bestR'] as num).toDouble(),
        bestL: (j['bestL'] as num).toDouble(),
        lastWeightR: (j['lastWeightR'] as num).toDouble(),
        lastWeightL: (j['lastWeightL'] as num).toDouble(),
      );
}

class LogInitData {
  const LogInitData({required this.workoutIdx, required this.exercises});

  final int workoutIdx;
  final List<LogExercise> exercises;

  factory LogInitData.fromJson(Map<String, dynamic> j) => LogInitData(
        workoutIdx: j['workoutIdx'] as int,
        exercises: (j['exercises'] as List)
            .map((e) => LogExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
