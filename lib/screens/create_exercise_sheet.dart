import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/native_bridge.dart';
import '../models/requests.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/color_utils.dart';
import '../widgets/app_toast.dart';

Future<void> openCreateExerciseSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateExerciseSheet(),
  );
}

class CreateExerciseSheet extends StatefulWidget {
  const CreateExerciseSheet({super.key});

  @override
  State<CreateExerciseSheet> createState() => _CreateExerciseSheetState();
}

class _CreateExerciseSheetState extends State<CreateExerciseSheet> {
  final _nameController = TextEditingController();
  String? _group;
  String _unit = 'reps';
  bool _saving = false;

  AppStateProvider get _provider => context.read<AppStateProvider>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _provider.meta;
    _group ??= meta.groups.first.id;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Новое упражнение',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.headingColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название', hintText: 'Например: Молот с гантелей'),
            ),
            const SizedBox(height: 16),
            const Text('Группа мышц', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in meta.groups)
                  _chip(
                    g.name,
                    _group == g.id,
                    () => setState(() => _group = g.id),
                    color: colorFromHex(g.color),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Единица измерения', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _unitButton('Повторения', 'reps')),
                const SizedBox(width: 8),
                Expanded(child: _unitButton('Секунды', 'sec')),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Создание…' : 'Создать упражнение'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitButton(String label, String value) {
    final selected = _unit == value;
    return GestureDetector(
      onTap: () => setState(() => _unit = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: selected ? AppColors.blue.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: selected ? AppColors.blue.withValues(alpha: 0.7) : AppColors.line2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? AppColors.blue : AppColors.muted),
        ),
      ),
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(context, 'Введи название упражнения');
      return;
    }
    setState(() => _saving = true);
    try {
      await _provider.addCustomExercise(CreateExerciseRequest(name: name, group: _group!, unit: _unit));
      if (mounted) {
        Navigator.pop(context);
        showAppToast(context, 'Упражнение добавлено');
      }
    } on NativeCallException catch (e) {
      if (mounted) showAppToast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
