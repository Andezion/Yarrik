class GroupDef {
  const GroupDef({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final String color; 

  factory GroupDef.fromJson(Map<String, dynamic> j) => GroupDef(
        id: j['id'] as String,
        name: j['name'] as String,
        color: j['color'] as String,
      );
}

class ExerciseDef {
  const ExerciseDef({
    required this.id,
    required this.name,
    required this.group,
    required this.unit,
  });

  final String id;
  final String name;
  final String group;
  final String unit; 

  bool get isTimed => unit == 'sec';

  factory ExerciseDef.fromJson(Map<String, dynamic> j) => ExerciseDef(
        id: j['id'] as String,
        name: j['name'] as String,
        group: j['group'] as String,
        unit: j['unit'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'unit': unit,
      };
}

class WorkoutDef {
  const WorkoutDef({
    required this.name,
    required this.exerciseIds,
    required this.color,
  });

  final String name;
  final List<String> exerciseIds;
  final String color;

  factory WorkoutDef.fromJson(Map<String, dynamic> j) => WorkoutDef(
        name: j['name'] as String,
        exerciseIds: (j['exerciseIds'] as List).cast<String>(),
        color: j['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'exerciseIds': exerciseIds,
        'color': color,
      };
}

class CatalogMeta {
  const CatalogMeta({
    required this.groups,
    required this.exercises,
    required this.workouts,
    required this.moods,
    required this.moodLabels,
    required this.fatigueColors,
  });

  final List<GroupDef> groups;
  final List<ExerciseDef> exercises;
  final List<WorkoutDef> workouts;
  final List<String> moods;
  final List<String> moodLabels;
  final List<String> fatigueColors;

  factory CatalogMeta.fromJson(Map<String, dynamic> j) => CatalogMeta(
        groups: (j['groups'] as List)
            .map((e) => GroupDef.fromJson(e as Map<String, dynamic>))
            .toList(),
        exercises: (j['exercises'] as List)
            .map((e) => ExerciseDef.fromJson(e as Map<String, dynamic>))
            .toList(),
        workouts: (j['workouts'] as List)
            .map((e) => WorkoutDef.fromJson(e as Map<String, dynamic>))
            .toList(),
        moods: (j['moods'] as List).cast<String>(),
        moodLabels: (j['moodLabels'] as List).cast<String>(),
        fatigueColors: (j['fatigueColors'] as List).cast<String>(),
      );

  ExerciseDef? exerciseById(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  GroupDef? groupById(String id) {
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }
}
