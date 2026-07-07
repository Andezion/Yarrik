library;

class CreateSetRequest {
  const CreateSetRequest({required this.arm, required this.weight, required this.reps});

  final String arm;
  final dynamic weight; 
  final dynamic reps;

  Map<String, dynamic> toJson() => {'arm': arm, 'weight': weight, 'reps': reps};
}

class CreateEntryRequest {
  const CreateEntryRequest({required this.exId, required this.sets});

  final String exId;
  final List<CreateSetRequest> sets;

  Map<String, dynamic> toJson() => {
        'exId': exId,
        'sets': sets.map((s) => s.toJson()).toList(),
      };
}

class CreateSessionRequest {
  const CreateSessionRequest({
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

  final String date;
  final int workoutIdx;
  final int? duration;
  final int? mood;
  final int? fatigue;
  final int? rpe;
  final String notes;
  final List<String> tags;
  final List<CreateEntryRequest> entries;

  Map<String, dynamic> toJson() => {
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

class CreateGoalRequest {
  const CreateGoalRequest({required this.exId, required this.arm, required this.target});

  final String exId;
  final String arm;
  final double target;

  Map<String, dynamic> toJson() => {'exId': exId, 'arm': arm, 'target': target};
}

class CreateExerciseRequest {
  const CreateExerciseRequest({required this.name, required this.group, required this.unit});

  final String name;
  final String group;
  final String unit;

  Map<String, dynamic> toJson() => {'name': name, 'group': group, 'unit': unit};
}

class CreateWorkoutRequest {
  const CreateWorkoutRequest({required this.name, required this.exerciseIds, required this.color});

  final String name;
  final List<String> exerciseIds;
  final String color;

  Map<String, dynamic> toJson() => {'name': name, 'exerciseIds': exerciseIds, 'color': color};
}
