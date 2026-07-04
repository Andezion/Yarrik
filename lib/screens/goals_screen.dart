import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/native_bridge.dart';
import '../models/catalog.dart';
import '../models/goal_view.dart';
import '../models/requests.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String? _newExerciseId;
  String _newArm = 'L';
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final meta = provider.meta;
    final goals = provider.compute.goals(provider.state);
    final tourney = provider.state.tourney;
    final daysToTourney = tourney.isNotEmpty ? daysBetween(todayIso(), tourney) : null;
    final wide = MediaQuery.sizeOf(context).width > 920;

    return ListView(
      children: [
        Text('Цели', style: Theme.of(context).textTheme.headlineSmall),
        const Text('Турнир и целевые веса по движениям', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CardTitle('Главный старт сезона'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        daysToTourney != null && daysToTourney >= 0 ? '$daysToTourney' : '—',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                      const Text('дней до турнира', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 26),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Дата турнира', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tourney.isNotEmpty ? parseIso(tourney) : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              await provider.updateTourneyDate(formatIso(picked));
                            }
                          },
                          child: Text(tourney.isNotEmpty ? fmtLong(tourney) : 'Выбрать дату'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'За 2 недели до старта — переход на подводку: снижай объём, сохраняй интенсивность.',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        wide ? _wideGoalsGrid(goals, meta) : _narrowGoalsList(goals, meta),
      ],
    );
  }

  Widget _wideGoalsGrid(List<GoalView> goals, CatalogMeta meta) {
    final cards = [
      for (final g in goals) _GoalCard(goal: g, onDelete: () => _deleteGoal(g.id)),
      _addGoalCard(meta),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.6,
      children: cards,
    );
  }

  Widget _narrowGoalsList(List<GoalView> goals, CatalogMeta meta) {
    return Column(
      children: [
        for (final g in goals)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GoalCard(goal: g, onDelete: () => _deleteGoal(g.id)),
          ),
        _addGoalCard(meta),
        const SizedBox(height: 90),
      ],
    );
  }

  Future<void> _deleteGoal(String id) async {
    await context.read<AppStateProvider>().deleteGoal(id);
  }

  Widget _addGoalCard(CatalogMeta meta) {
    _newExerciseId ??= meta.exercises.first.id;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Новая цель'),
          DropdownButtonFormField<String>(
            value: _newExerciseId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Упражнение'),
            items: [
              for (final ex in meta.exercises) DropdownMenuItem(value: ex.id, child: Text(ex.name)),
            ],
            onChanged: (v) => setState(() => _newExerciseId = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _newArm,
            decoration: const InputDecoration(labelText: 'Рука'),
            items: const [
              DropdownMenuItem(value: 'L', child: Text('Левая')),
              DropdownMenuItem(value: 'R', child: Text('Правая')),
            ],
            onChanged: (v) => setState(() => _newArm = v ?? 'L'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Целевой вес, кг'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final target = double.tryParse(_targetController.text.replaceAll(',', '.'));
              if (target == null || target <= 0) {
                showAppToast(context, 'Укажи целевой вес');
                return;
              }
              try {
                await context.read<AppStateProvider>().addGoal(
                      CreateGoalRequest(exId: _newExerciseId!, arm: _newArm, target: target),
                    );
                _targetController.clear();
                if (mounted) showAppToast(context, 'Цель добавлена');
              } on NativeCallException catch (e) {
                if (mounted) showAppToast(context, e.message);
              }
            },
            child: const Text('Добавить цель'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onDelete});

  final GoalView goal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = goal.arm == 'R' ? const Color(0xFF2E9825) : AppColors.blue;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${goal.exerciseName} · ${goal.arm == 'R' ? 'правая' : 'левая'}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Text('убрать', style: TextStyle(color: AppColors.red, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${goal.current}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(' / ${goal.target} кг · ${goal.pct}%', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              if (goal.pct >= 100)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Достигнута!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.pct / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFF3C82BE).withValues(alpha: 0.14),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
