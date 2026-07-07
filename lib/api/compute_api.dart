import '../models/app_state.dart';
import '../models/build_session_result.dart';
import '../models/calendar_data.dart';
import '../models/catalog.dart';
import '../models/dashboard_data.dart';
import '../models/exercise_row.dart';
import '../models/goal_view.dart';
import '../models/import_result.dart';
import '../models/log_init.dart';
import '../models/requests.dart';
import '../models/session_view.dart';
import '../models/stats_data.dart';
import 'native_bridge.dart';

class ComputeApi {
  ComputeApi([NativeBridge? bridge]) : _bridge = bridge ?? NativeBridge();

  final NativeBridge _bridge;

  CatalogMeta meta() {
    final data = _bridge.call('meta', {});
    return CatalogMeta.fromJson(data as Map<String, dynamic>);
  }

  DashboardData dashboard(AppState state) {
    final data = _bridge.call('dashboard', {'state': state.toJson()});
    return DashboardData.fromJson(data as Map<String, dynamic>);
  }

  List<SessionView> sessions(
    AppState state, {
    String query = '',
    int? workoutIdx,
    String groupId = '',
  }) {
    final data = _bridge.call('sessions', {
      'state': state.toJson(),
      'query': query,
      'workoutIdx': workoutIdx,
      'groupId': groupId,
    });
    return (data as List)
        .map((e) => SessionView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<SessionView> sessionsOnDate(AppState state, String date) {
    final data = _bridge.call('sessionsOnDate', {'state': state.toJson(), 'date': date});
    return (data as List)
        .map((e) => SessionView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  BuildSessionResult buildSession(AppState state, CreateSessionRequest request, int currentCursor) {
    final data = _bridge.call('buildSession', {
      'state': state.toJson(),
      'request': request.toJson(),
      'currentCursor': currentCursor,
    });
    return BuildSessionResult.fromJson(data as Map<String, dynamic>);
  }

  CalendarData calendar(AppState state, int year, int month) {
    final data = _bridge.call('calendar', {'state': state.toJson(), 'year': year, 'month': month});
    return CalendarData.fromJson(data as Map<String, dynamic>);
  }

  StatsData stats(AppState state, String exerciseId) {
    final data = _bridge.call('stats', {'state': state.toJson(), 'exerciseId': exerciseId});
    return StatsData.fromJson(data as Map<String, dynamic>);
  }

  List<ExerciseRow> exercisesTable(AppState state) {
    final data = _bridge.call('exercisesTable', {'state': state.toJson()});
    return (data as List)
        .map((e) => ExerciseRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ExerciseDetail exerciseDetail(AppState state, String exerciseId) {
    final data = _bridge.call('exerciseDetail', {'state': state.toJson(), 'exerciseId': exerciseId});
    return ExerciseDetail.fromJson(data as Map<String, dynamic>);
  }

  List<GoalView> goals(AppState state) {
    final data = _bridge.call('goals', {'state': state.toJson()});
    return (data as List)
        .map((e) => GoalView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> buildGoal(AppState state, CreateGoalRequest request) {
    final data = _bridge.call('buildGoal', {'state': state.toJson(), 'request': request.toJson()});
    return data as Map<String, dynamic>;
  }

  LogInitData logInit(AppState state, {int? workoutIdx}) {
    final data = _bridge.call('logInit', {'state': state.toJson(), 'workoutIdx': workoutIdx});
    return LogInitData.fromJson(data as Map<String, dynamic>);
  }

  ImportResult importAny(Map<String, dynamic> raw, AppState current) {
    final data = _bridge.call('importAny', {'raw': raw, 'current': current.toJson()});
    return ImportResult.fromJson(data as Map<String, dynamic>);
  }

  ExerciseDef createExercise(AppState state, CreateExerciseRequest request) {
    final data = _bridge.call('createExercise', {'state': state.toJson(), 'request': request.toJson()});
    return ExerciseDef.fromJson(data as Map<String, dynamic>);
  }

  WorkoutDef createWorkout(AppState state, CreateWorkoutRequest request) {
    final data = _bridge.call('createWorkout', {'state': state.toJson(), 'request': request.toJson()});
    return WorkoutDef.fromJson(data as Map<String, dynamic>);
  }
}
