import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/native_bridge.dart';
import '../models/log_init.dart';
import '../models/requests.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/app_toast.dart';

Future<void> openLogWorkoutSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const LogWorkoutSheet(),
  );
}

class _SetRow {
  _SetRow(this.arm, double weight, double reps)
      : weightController = TextEditingController(text: weight > 0 ? _fmt(weight) : ''),
        repsController = TextEditingController(text: reps > 0 ? _fmt(reps) : '');

  final String arm;
  final TextEditingController weightController;
  final TextEditingController repsController;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class LogWorkoutSheet extends StatefulWidget {
  const LogWorkoutSheet({super.key});

  @override
  State<LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends State<LogWorkoutSheet> {
  int? _workoutIdx;
  DateTime _date = DateTime.now();
  final Map<String, List<_SetRow>> _sets = {}; 
  LogInitData? _init;

  int _duration = 0;
  int _rpe = 7;
  int _mood = 2;
  int _fatigue = 2;
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();

  AppStateProvider get _provider => context.read<AppStateProvider>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init == null) {
      _loadWorkout(null);
    }
  }

  void _loadWorkout(int? idx) {
    final init = _provider.compute.logInit(_provider.state, workoutIdx: idx);
    setState(() {
      _init = init;
      _workoutIdx = init.workoutIdx;
      for (final rows in _sets.values) {
        for (final r in rows) {
          r.dispose();
        }
      }
      _sets.clear();
      for (final ex in init.exercises) {
        _sets[ex.exId] = [
          _SetRow('R', ex.lastWeightR, 0),
          _SetRow('R', ex.lastWeightR, 0),
          _SetRow('R', ex.lastWeightR, 0),
          _SetRow('L', ex.lastWeightL, 0),
          _SetRow('L', ex.lastWeightL, 0),
          _SetRow('L', ex.lastWeightL, 0),
        ];
      }
    });
  }

  @override
  void dispose() {
    for (final rows in _sets.values) {
      for (final r in rows) {
        r.dispose();
      }
    }
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addSet(String exId, String arm) {
    final rows = _sets[exId]!;
    _SetRow? lastOfArm;
    for (final r in rows.reversed) {
      if (r.arm == arm) {
        lastOfArm = r;
        break;
      }
    }
    setState(() {
      final insertAt = rows.lastIndexWhere((r) => r.arm == arm) + 1;
      rows.insert(
        insertAt,
        _SetRow(arm, double.tryParse(lastOfArm?.weightController.text.replaceAll(',', '.') ?? '') ?? 0,
            double.tryParse(lastOfArm?.repsController.text.replaceAll(',', '.') ?? '') ?? 0),
      );
    });
  }

  void _removeSet(String exId, String arm) {
    final rows = _sets[exId]!;
    final armRows = rows.where((r) => r.arm == arm).toList();
    if (armRows.length <= 1) return;
    setState(() {
      final last = rows.lastIndexWhere((r) => r.arm == arm);
      rows.removeAt(last).dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final init = _init;
    final meta = _provider.meta;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: init == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                controller: controller,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Записать тренировку',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < meta.workouts.length; i++)
                        _chip(
                          meta.workouts[i].name.replaceFirst('Тренировка', 'Тр.'),
                          _workoutIdx == i,
                          () => _loadWorkout(i),
                          color: colorFromHex(meta.workouts[i].color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(fmtLong(formatIso(_date))),
                  ),
                  const SizedBox(height: 14),
                  for (final ex in init.exercises) _exerciseBlock(ex),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Длительность, мин'),
                          onChanged: (v) => _duration = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('RPE тренировки · $_rpe/10', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  Slider(
                    value: _rpe.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.orange,
                    onChanged: (v) => setState(() => _rpe = v.round()),
                  ),
                  const SizedBox(height: 8),
                  const Text('Самочувствие', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (var i = 0; i < meta.moods.length; i++)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mood = i),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: _mood == i ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                border: Border.all(
                                  color: _mood == i ? AppColors.blue.withValues(alpha: 0.8) : AppColors.line2,
                                ),
                              ),
                              child: Center(
                                child: Text(meta.moods[i], style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Усталость после', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (var f = 1; f <= 5; f++)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _fatigue = f),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: _fatigue == f ? AppColors.fatigueColor(f) : Colors.white.withValues(alpha: 0.5),
                                border: Border.all(color: AppColors.line2),
                              ),
                              child: Center(
                                child: Text(
                                  '$f',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _fatigue == f ? Colors.white : AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(labelText: 'Теги (через запятую)', hintText: 'техника, тяжёлая…'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Заметки',
                      hintText: 'Как шёл крюк, что с локтем, какие углы…',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Сохранить тренировку'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }

  Widget _exerciseBlock(LogExercise ex) {
    final rows = _sets[ex.exId]!;
    final rRows = rows.where((r) => r.arm == 'R').toList();
    final lRows = rows.where((r) => r.arm == 'L').toList();
    final repLabel = ex.unit == 'sec' ? 'сек' : 'повт';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.headingColor)),
          Text(
            'Рекорд: ${ex.bestR > 0 ? ex.bestR : '—'} / ${ex.bestL > 0 ? ex.bestL : '—'} кг',
            style: const TextStyle(fontSize: 11, color: AppColors.dim),
          ),
          const SizedBox(height: 8),
          _armSection('Правая', AppColors.orangeLight, rRows, ex.exId, 'R', repLabel),
          const SizedBox(height: 8),
          _armSection('Левая', AppColors.blue, lRows, ex.exId, 'L', repLabel),
        ],
      ),
    );
  }

  Widget _armSection(String label, Color color, List<_SetRow> rows, String exId, String arm, String repLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: color)),
        const SizedBox(height: 4),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: row.weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'кг', isDense: true),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('×', style: TextStyle(color: AppColors.dim))),
                Expanded(
                  child: TextField(
                    controller: row.repsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: repLabel, isDense: true),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            TextButton(onPressed: () => _addSet(exId, arm), child: const Text('+ подход')),
            TextButton(onPressed: () => _removeSet(exId, arm), child: const Text('−')),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap, {required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected ? color.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: selected ? color.withValues(alpha: 0.7) : AppColors.line2),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? color : AppColors.muted),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final entries = <CreateEntryRequest>[];
    for (final entry in _sets.entries) {
      final sets = <CreateSetRequest>[];
      for (final row in entry.value) {
        final weight = row.weightController.text.trim();
        final reps = row.repsController.text.trim();
        if (weight.isEmpty || reps.isEmpty) continue;
        sets.add(CreateSetRequest(arm: row.arm, weight: weight, reps: reps));
      }
      if (sets.isNotEmpty) {
        entries.add(CreateEntryRequest(exId: entry.key, sets: sets));
      }
    }

    final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final request = CreateSessionRequest(
      date: formatIso(_date),
      workoutIdx: _workoutIdx!,
      duration: _duration > 0 ? _duration : null,
      mood: _mood,
      fatigue: _fatigue,
      rpe: _rpe,
      notes: _notesController.text.trim(),
      tags: tags,
      entries: entries,
    );

    try {
      await _provider.logSession(request);
      if (mounted) {
        Navigator.pop(context);
        showAppToast(context, 'Тренировка записана 💪');
      }
    } on NativeCallException catch (e) {
      if (mounted) showAppToast(context, e.message);
    }
  }
}
