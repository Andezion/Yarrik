class GoalView {
  const GoalView({
    required this.id,
    required this.exId,
    required this.exerciseName,
    required this.arm,
    required this.target,
    required this.current,
    required this.pct,
  });

  final String id;
  final String exId;
  final String exerciseName;
  final String arm;
  final double target;
  final double current;
  final int pct;

  factory GoalView.fromJson(Map<String, dynamic> j) => GoalView(
        id: j['id'] as String,
        exId: j['exId'] as String,
        exerciseName: (j['exerciseName'] as String?) ?? '',
        arm: j['arm'] as String,
        target: (j['target'] as num).toDouble(),
        current: (j['current'] as num).toDouble(),
        pct: j['pct'] as int,
      );
}
