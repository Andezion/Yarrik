import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_state.dart';

class StorageService {
  static const _fileName = 'armforge_state.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<AppState> load() async {
    final file = await _file();
    if (!await file.exists()) {
      await save(AppState.empty);
      return AppState.empty;
    }
    try {
      final raw = await file.readAsString();
      return AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await save(AppState.empty);
      return AppState.empty;
    }
  }

  Future<void> save(AppState state) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(state.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}
