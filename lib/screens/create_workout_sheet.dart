import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/native_bridge.dart';
import '../models/requests.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../widgets/aero_button.dart';
import '../widgets/aero_sheet.dart';
import '../widgets/app_toast.dart';

const _kWorkoutColorPalette = [
  '#FF8A24',
  '#1E9BE9',
  '#EFAF1B',
  '#52BD3A',
  '#9D6FE8',
  '#E14B38',
  '#0FA8DE',
  '#3BAF1E',
];

const _kMaxWorkoutExercises = 6;

Future<void> openCreateWorkoutSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateWorkoutSheet(),
  );
}

class CreateWorkoutSheet extends StatefulWidget {
  const CreateWorkoutSheet({super.key});

  @override
  State<CreateWorkoutSheet> createState() => _CreateWorkoutSheetState();
}

class _CreateWorkoutSheetState extends State<CreateWorkoutSheet> {
  final _nameController = TextEditingController();
  final Set<String> _selectedExerciseIds = {};
  String _color = _kWorkoutColorPalette.first;
  bool _saving = false;

  AppStateProvider get _provider => context.read<AppStateProvider>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExercise(String id) {
    setState(() {
      if (_selectedExerciseIds.contains(id)) {
        _selectedExerciseIds.remove(id);
      } else if (_selectedExerciseIds.length < _kMaxWorkoutExercises) {
        _selectedExerciseIds.add(id);
      } else {
        showAppToast(context, 'Максимум $_kMaxWorkoutExercises упражнений в тренировке');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _provider.allExercises;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, controller) => Container(
        decoration: aeroSheetDecoration(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: ListView(
          controller: controller,
          children: [
            const SheetHandle(),
            const SheetHeader(title: 'Новая тренировка'),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название', hintText: 'Например: Тренировка 6'),
            ),
            const SizedBox(height: 16),
            Text('Упражнения · ${_selectedExerciseIds.length}/$_kMaxWorkoutExercises',
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 8),
            for (final ex in exercises)
              CheckboxListTile(
                value: _selectedExerciseIds.contains(ex.id),
                onChanged: (_) => _toggleExercise(ex.id),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppColors.aquaDeep,
                title: Text(ex.name, style: const TextStyle(fontSize: 13.5)),
              ),
            const SizedBox(height: 12),
            const SheetLabel('Цвет'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in _kWorkoutColorPalette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colorFromHex(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == hex ? Colors.white : Colors.white.withValues(alpha: 0.7),
                          width: _color == hex ? 3 : 2,
                        ),
                        boxShadow: _color == hex
                            ? [BoxShadow(color: colorFromHex(hex).withValues(alpha: 0.6), blurRadius: 10)]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: AeroButton(
                label: _saving ? 'Создание…' : 'Создать тренировку',
                expand: true,
                onPressed: _saving ? null : _save,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(context, 'Введи название тренировки');
      return;
    }
    if (_selectedExerciseIds.isEmpty) {
      showAppToast(context, 'Выбери хотя бы одно упражнение');
      return;
    }
    setState(() => _saving = true);
    try {
      await _provider.addCustomWorkout(
        CreateWorkoutRequest(name: name, exerciseIds: _selectedExerciseIds.toList(), color: _color),
      );
      if (mounted) {
        Navigator.pop(context);
        showAppToast(context, 'Тренировка добавлена');
      }
    } on NativeCallException catch (e) {
      if (mounted) showAppToast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
