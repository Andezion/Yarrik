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
        decoration: aeroSheetDecoration(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SheetHeader(title: 'Новое упражнение'),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название', hintText: 'Например: Молот с гантелей'),
            ),
            const SizedBox(height: 18),
            const SheetLabel('Группа мышц'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in meta.groups)
                  AeroChip(
                    label: g.name,
                    selected: _group == g.id,
                    accentColor: colorFromHex(g.color),
                    onTap: () => setState(() => _group = g.id),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const SheetLabel('Единица измерения'),
            Row(
              children: [
                Expanded(child: _unitButton('Повторения', 'reps')),
                const SizedBox(width: 8),
                Expanded(child: _unitButton('Секунды', 'sec')),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: AeroButton(
                label: _saving ? 'Создание…' : 'Создать упражнение',
                expand: true,
                onPressed: _saving ? null : _save,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFA9EEFF), Color(0xFF4FD4F8), Color(0xFF17B2E8), Color(0xFF5CD8F8)],
                  stops: [0, 0.48, 0.52, 1],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: selected ? AppColors.aquaDeep.withValues(alpha: 0.6) : AppColors.line2),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.aqua.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.muted,
          ),
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
