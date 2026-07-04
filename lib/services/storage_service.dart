import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../api/compute_api.dart';
import '../models/app_state.dart';

class StorageService {
  StorageService([ComputeApi? computeApi]) : _computeApi = computeApi ?? ComputeApi();

  static const _fileName = 'armforge_state.json';
  final ComputeApi _computeApi;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<AppState> load() async {
    final file = await _file();
    if (!await file.exists()) {
      final seeded = _computeApi.genDemo();
      await save(seeded);
      return seeded;
    }
    try {
      final raw = await file.readAsString();
      final state = AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (state.sessions.isEmpty) {
        final seeded = _computeApi.genDemo();
        await save(seeded);
        return seeded;
      }
      return state;
    } catch (_) {
      final seeded = _computeApi.genDemo();
      await save(seeded);
      return seeded;
    }
  }

  Future<void> save(AppState state) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(state.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}
