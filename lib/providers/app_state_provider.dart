import 'package:flutter/foundation.dart';

import '../api/compute_api.dart';
import '../models/app_state.dart';
import '../models/catalog.dart';
import '../models/requests.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';


class AppStateProvider extends ChangeNotifier {
  AppStateProvider({ComputeApi? computeApi, StorageService? storage})
      : _computeApi = computeApi ?? ComputeApi(),
        _storage = storage ?? StorageService();

  final ComputeApi _computeApi;
  final StorageService _storage;

  AppState _state = AppState.empty;
  AppState get state => _state;

  CatalogMeta? _meta;
  CatalogMeta get meta => _meta!;

  bool _loading = true;
  bool get loading => _loading;

  ComputeApi get compute => _computeApi;

  Future<void> load() async {
    _meta = _computeApi.meta();
    _state = await _storage.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save(_state);
    notifyListeners();
  }

  Future<void> logSession(CreateSessionRequest request) async {
    final result = _computeApi.buildSession(request, _state.cursor);
    _state = _state.copyWith(
      sessions: [..._state.sessions, result.session],
      cursor: result.newCursor,
      demo: false,
    );
    await _persist();
  }

  Future<void> deleteSession(String id) async {
    _state = _state.copyWith(
      sessions: _state.sessions.where((s) => s.id != id).toList(),
    );
    await _persist();
  }

  Future<void> addGoal(CreateGoalRequest request) async {
    final goalJson = _computeApi.buildGoal(request);
    _state = _state.copyWith(
      goals: [..._state.goals, Goal.fromJson(goalJson)],
    );
    await _persist();
  }

  Future<void> deleteGoal(String id) async {
    _state = _state.copyWith(
      goals: _state.goals.where((g) => g.id != id).toList(),
    );
    await _persist();
  }

  
  Future<void> addBodyweight(double kg) async {
    final today = todayIso();
    final next = _state.bw.where((b) => b.date != today).toList()
      ..add(Bodyweight(date: today, kg: kg));
    _state = _state.copyWith(bw: next);
    await _persist();
  }

  Future<void> deleteBodyweight(String date) async {
    _state = _state.copyWith(
      bw: _state.bw.where((b) => b.date != date).toList(),
    );
    await _persist();
  }

  Future<void> updateName(String name) async {
    _state = _state.copyWith(name: name);
    await _persist();
  }

  Future<void> updateTourneyDate(String isoDate) async {
    _state = _state.copyWith(tourney: isoDate);
    await _persist();
  }

  Future<void> importBackup(Map<String, dynamic> raw) async {
    final result = _computeApi.importAny(raw, _state);
    _state = _state.copyWith(
      name: result.name,
      cursor: result.cursor,
      sessions: result.sessions,
      bw: result.bw,
      goals: result.goals,
      tourney: result.tourney,
      demo: false,
    );
    await _persist();
  }

  Map<String, dynamic> exportBackup() => {
        'name': _state.name,
        'cursor': _state.cursor,
        'sessions': _state.sessions.map((s) => s.toJson()).toList(),
        'bw': _state.bw.map((b) => b.toJson()).toList(),
        'goals': _state.goals.map((g) => g.toJson()).toList(),
        'tourney': _state.tourney,
      };

  Future<void> wipeAll() async {
    _state = _state.copyWith(
      sessions: [],
      bw: [],
      goals: [],
      cursor: 0,
      demo: false,
    );
    await _persist();
  }
}
