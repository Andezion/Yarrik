library;

class SetView {
  const SetView({required this.arm, required this.weight, required this.reps});

  final String arm;
  final double weight;
  final double reps;

  factory SetView.fromJson(Map<String, dynamic> j) => SetView(
        arm: j['arm'] as String,
        weight: (j['weight'] as num).toDouble(),
        reps: (j['reps'] as num).toDouble(),
      );
}

class EntryView {
  const EntryView({
    required this.exId,
    required this.exerciseName,
    required this.unit,
    required this.groupId,
    required this.groupColor,
    required this.notes,
    required this.sets,
  });

  final String exId;
  final String exerciseName;
  final String unit;
  final String groupId;
  final String groupColor;
  final String notes;
  final List<SetView> sets;

  List<SetView> setsForArm(String arm) =>
      sets.where((s) => s.arm == arm).toList();

  factory EntryView.fromJson(Map<String, dynamic> j) => EntryView(
        exId: j['exId'] as String,
        exerciseName: (j['exerciseName'] as String?) ?? '',
        unit: (j['unit'] as String?) ?? 'reps',
        groupId: (j['groupId'] as String?) ?? '',
        groupColor: (j['groupColor'] as String?) ?? '#1E7FD6',
        notes: (j['notes'] as String?) ?? '',
        sets: (j['sets'] as List)
            .map((e) => SetView.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SessionView {
  const SessionView({
    required this.id,
    required this.date,
    required this.workoutIdx,
    required this.workoutName,
    required this.workoutColor,
    required this.duration,
    required this.mood,
    required this.moodEmoji,
    required this.moodLabel,
    required this.fatigue,
    required this.fatigueColor,
    required this.rpe,
    required this.notes,
    required this.tags,
    required this.entries,
    required this.score,
    required this.scoreColor,
    required this.volume,
    required this.setsCount,
  });

  final String id;
  final String date;
  final int workoutIdx;
  final String workoutName;
  final String workoutColor;
  final int? duration;
  final int? mood;
  final String? moodEmoji;
  final String? moodLabel;
  final int? fatigue;
  final String? fatigueColor;
  final int? rpe;
  final String notes;
  final List<String> tags;
  final List<EntryView> entries;
  final int score;
  final String scoreColor;
  final double volume;
  final int setsCount;

  factory SessionView.fromJson(Map<String, dynamic> j) => SessionView(
        id: j['id'] as String,
        date: j['date'] as String,
        workoutIdx: j['workoutIdx'] as int,
        workoutName: (j['workoutName'] as String?) ?? '',
        workoutColor: (j['workoutColor'] as String?) ?? '#1E7FD6',
        duration: j['duration'] as int?,
        mood: j['mood'] as int?,
        moodEmoji: j['moodEmoji'] as String?,
        moodLabel: j['moodLabel'] as String?,
        fatigue: j['fatigue'] as int?,
        fatigueColor: j['fatigueColor'] as String?,
        rpe: j['rpe'] as int?,
        notes: (j['notes'] as String?) ?? '',
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
        entries: (j['entries'] as List)
            .map((e) => EntryView.fromJson(e as Map<String, dynamic>))
            .toList(),
        score: (j['score'] as int?) ?? 0,
        scoreColor: (j['scoreColor'] as String?) ?? '#E8564E',
        volume: (j['volume'] as num?)?.toDouble() ?? 0,
        setsCount: (j['setsCount'] as int?) ?? 0,
      );
}
