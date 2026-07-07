import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/native_bridge.dart';
import '../models/requests.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/color_utils.dart';
import '../widgets/app_toast.dart';

const _kWorkoutColorPalette = [
  '#2E97E5',
  '#17B8A6',
  '#F2A93B',
  '#57C84D',
  '#9A7BE8',
  '#E8564E',
  '#F5822E',
  '#2FA344',
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
        decoration: const BoxDecoration(
          color: Color(0xFFF3FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: ListView(
          controller: controller,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Новая тренировка',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
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
                title: Text(ex.name, style: const TextStyle(fontSize: 13.5)),
              ),
            const SizedBox(height: 12),
            const Text('Цвет', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in _kWorkoutColorPalette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorFromHex(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == hex ? AppColors.text : Colors.white,
                          width: _color == hex ? 3 : 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Создание…' : 'Создать тренировку'),
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
