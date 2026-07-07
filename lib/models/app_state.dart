import 'catalog.dart';
import 'session.dart';

class Bodyweight {
  const Bodyweight({required this.date, required this.kg});

  final String date;
  final double kg;

  factory Bodyweight.fromJson(Map<String, dynamic> j) => Bodyweight(
        date: j['date'] as String,
        kg: (j['kg'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'date': date, 'kg': kg};
}

class Goal {
  const Goal({
    required this.id,
    required this.exId,
    required this.arm,
    required this.target,
  });

  final String id;
  final String exId;
  final String arm;
  final double target;

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'] as String,
        exId: j['exId'] as String,
        arm: j['arm'] as String,
        target: (j['target'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'exId': exId,
        'arm': arm,
        'target': target,
      };
}

class AppState {
  const AppState({
    required this.name,
    required this.cursor,
    required this.sessions,
    required this.bw,
    required this.goals,
    required this.tourney,
    required this.customExercises,
    required this.customWorkouts,
  });

  final String name;
  final int cursor;
  final List<Session> sessions;
  final List<Bodyweight> bw;
  final List<Goal> goals;
  final String tourney;
  final List<ExerciseDef> customExercises;
  final List<WorkoutDef> customWorkouts;

  factory AppState.fromJson(Map<String, dynamic> j) => AppState(
        name: (j['name'] as String?) ?? '',
        cursor: (j['cursor'] as int?) ?? 0,
        sessions: ((j['sessions'] as List?) ?? const [])
            .map((e) => Session.fromJson(e as Map<String, dynamic>))
            .toList(),
        bw: ((j['bw'] as List?) ?? const [])
            .map((e) => Bodyweight.fromJson(e as Map<String, dynamic>))
            .toList(),
        goals: ((j['goals'] as List?) ?? const [])
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList(),
        tourney: (j['tourney'] as String?) ?? '',
        customExercises: ((j['customExercises'] as List?) ?? const [])
            .map((e) => ExerciseDef.fromJson(e as Map<String, dynamic>))
            .toList(),
        customWorkouts: ((j['customWorkouts'] as List?) ?? const [])
            .map((e) => WorkoutDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'cursor': cursor,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'bw': bw.map((b) => b.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        'tourney': tourney,
        'customExercises': customExercises.map((e) => e.toJson()).toList(),
        'customWorkouts': customWorkouts.map((w) => w.toJson()).toList(),
      };

  AppState copyWith({
    String? name,
    int? cursor,
    List<Session>? sessions,
    List<Bodyweight>? bw,
    List<Goal>? goals,
    String? tourney,
    List<ExerciseDef>? customExercises,
    List<WorkoutDef>? customWorkouts,
  }) {
    return AppState(
      name: name ?? this.name,
      cursor: cursor ?? this.cursor,
      sessions: sessions ?? this.sessions,
      bw: bw ?? this.bw,
      goals: goals ?? this.goals,
      tourney: tourney ?? this.tourney,
      customExercises: customExercises ?? this.customExercises,
      customWorkouts: customWorkouts ?? this.customWorkouts,
    );
  }

  static const empty = AppState(
    name: '',
    cursor: 0,
    sessions: [],
    bw: [],
    goals: [],
    tourney: '',
    customExercises: [],
    customWorkouts: [],
  );
}
