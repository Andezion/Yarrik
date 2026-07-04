library;

class WorkSet {
  const WorkSet({required this.arm, required this.weight, required this.reps});

  final String arm; 
  final double weight;
  final double reps;

  factory WorkSet.fromJson(Map<String, dynamic> j) => WorkSet(
        arm: (j['arm'] as String?) ?? 'R',
        weight: (j['weight'] as num).toDouble(),
        reps: (j['reps'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'arm': arm, 'weight': weight, 'reps': reps};

  WorkSet copyWith({String? arm, double? weight, double? reps}) => WorkSet(
        arm: arm ?? this.arm,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
      );
}

class SessionEntry {
  const SessionEntry({required this.exId, required this.sets, this.notes = ''});

  final String exId;
  final List<WorkSet> sets;
  final String notes;

  factory SessionEntry.fromJson(Map<String, dynamic> j) => SessionEntry(
        exId: j['exId'] as String,
        notes: (j['notes'] as String?) ?? '',
        sets: (j['sets'] as List)
            .map((e) => WorkSet.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'exId': exId,
        'notes': notes,
        'sets': sets.map((s) => s.toJson()).toList(),
      };
}

class Session {
  const Session({
    required this.id,
    required this.date,
    required this.workoutIdx,
    required this.entries,
    this.duration,
    this.mood,
    this.fatigue,
    this.rpe,
    this.notes = '',
    this.tags = const [],
  });

  final String id;
  final String date; 
  final int workoutIdx;
  final int? duration;
  final int? mood; 
  final int? fatigue;
  final int? rpe;
  final String notes;
  final List<String> tags;
  final List<SessionEntry> entries;

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        date: j['date'] as String,
        workoutIdx: j['workoutIdx'] as int,
        duration: j['duration'] as int?,
        mood: j['mood'] as int?,
        fatigue: j['fatigue'] as int?,
        rpe: j['rpe'] as int?,
        notes: (j['notes'] as String?) ?? '',
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
        entries: (j['entries'] as List)
            .map((e) => SessionEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'workoutIdx': workoutIdx,
        'duration': duration,
        'mood': mood,
        'fatigue': fatigue,
        'rpe': rpe,
        'notes': notes,
        'tags': tags,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}
