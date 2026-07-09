import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/color_utils.dart';
import '../widgets/aero_button.dart';
import '../widgets/app_toast.dart';
import '../widgets/session_card.dart';
import 'create_workout_sheet.dart';
import 'log_workout_sheet.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String _query = '';
  int? _workoutFilter;
  String _groupFilter = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final meta = provider.meta;
    final sessions = provider.compute.sessions(
      provider.state,
      query: _query,
      workoutIdx: _workoutFilter,
      groupId: _groupFilter,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Дневник тренировок', style: Theme.of(context).textTheme.headlineSmall),
            ),
            AeroButton(
              label: 'Записать',
              icon: Icons.add,
              onPressed: () => openLogWorkoutSheet(context),
            ),
          ],
        ),
        Text(
          '${provider.state.sessions.length} записей · таймлайн всех сессий',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Поиск: упражнение, заметка, тег…',
            prefixIcon: Icon(Icons.search, size: 20),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < provider.allWorkouts.length; i++)
              AeroChip(
                label: provider.allWorkouts[i].name.replaceFirst('Тренировка', 'Тр.'),
                selected: _workoutFilter == i,
                accentColor: colorFromHex(provider.allWorkouts[i].color),
                onTap: () => setState(() => _workoutFilter = _workoutFilter == i ? null : i),
              ),
            for (final g in meta.groups)
              AeroChip(
                label: g.name,
                selected: _groupFilter == g.id,
                accentColor: colorFromHex(g.color),
                onTap: () => setState(() => _groupFilter = _groupFilter == g.id ? '' : g.id),
              ),
            AeroChip(
              label: '+ Тренировка',
              selected: false,
              onTap: () => openCreateWorkoutSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: sessions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Ничего не найдено. Измени фильтры — или запиши первую тренировку кнопкой «+».',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final s = sessions[i];
                    return SessionCard(
                      session: s,
                      onDelete: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Удалить эту тренировку из дневника?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await provider.deleteSession(s.id);
                          if (context.mounted) showAppToast(context, 'Запись удалена');
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
