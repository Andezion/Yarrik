import 'app_state.dart';
import 'session.dart';


class ImportResult {
  const ImportResult({
    required this.name,
    required this.cursor,
    required this.sessions,
    required this.bw,
    required this.goals,
    required this.tourney,
  });

  final String name;
  final int cursor;
  final List<Session> sessions;
  final List<Bodyweight> bw;
  final List<Goal> goals;
  final String tourney;

  factory ImportResult.fromJson(Map<String, dynamic> j) => ImportResult(
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
      );
}
