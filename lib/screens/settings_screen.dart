import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../api/native_bridge.dart';
import '../providers/app_state_provider.dart';
import '../themes/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _bwController = TextEditingController();
  bool _nameSeeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final state = provider.state;
    if (!_nameSeeded) {
      _nameController.text = state.name;
      _nameSeeded = true;
    }
    final wide = MediaQuery.sizeOf(context).width > 920;
    final bwSorted = [...state.bw]..sort((a, b) => b.date.compareTo(a.date));

    final cards = [
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardTitle('Профиль'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
              onSubmitted: (v) async {
                await provider.updateName(v);
                if (context.mounted) showAppToast(context, 'Сохранено');
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Категория: 87 кг · стили: крюк, бок—крюк · ведущая — левая.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardTitle('Вес тела'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bwController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '87.4'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () async {
                    final kg = double.tryParse(_bwController.text.replaceAll(',', '.'));
                    if (kg == null || kg <= 0) {
                      showAppToast(context, 'Введи вес');
                      return;
                    }
                    await provider.addBodyweight(kg);
                    _bwController.clear();
                    if (context.mounted) showAppToast(context, 'Вес записан');
                  },
                  child: const Text('Записать'),
                ),
              ],
            ),
            for (final b in bwSorted.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(fmtLong(b.date), style: const TextStyle(fontSize: 13))),
                    Text('${b.kg} кг', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => provider.deleteBodyweight(b.date),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardTitle('Данные'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _exportBackup(context, provider),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Скачать копию'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _importBackup(context, provider),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Загрузить копию'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _wipeAll(context, provider),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Стереть всё'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Данные живут на этом устройстве. Поддерживается загрузка старых копий из «arm_dnevnik_simple» — записи сгруппируются в тренировки автоматически. Делай копию перед сбросом курса.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      const GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardTitle('О приложении'),
            Text(
              'ARMFORGE · дневник армрестлера.\n'
              '5 тренировок × 3 упражнения по кругу.\n'
              'Правая — оранжевый, левая — синий. Везде.',
              style: TextStyle(color: AppColors.muted, height: 1.7),
            ),
          ],
        ),
      ),
    ];

    return ListView(
      children: [
        Text('Настройки', style: Theme.of(context).textTheme.headlineSmall),
        const Text('Профиль, вес тела и данные', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 16),
        if (wide)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: cards,
          )
        else
          Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 16), child: c)]),
        const SizedBox(height: 90),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context, AppStateProvider provider) async {
    final backup = provider.exportBackup();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/armforge_backup_${todayIso()}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(backup));
    if (!context.mounted) return;
    await Share.shareXFiles([XFile(file.path)], text: 'ARMFORGE — резервная копия дневника');
  }

  Future<void> _importBackup(BuildContext context, AppStateProvider provider) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final raw = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      await provider.importBackup(raw);
      if (context.mounted) showAppToast(context, 'Данные загружены');
    } on NativeCallException catch (e) {
      if (context.mounted) showAppToast(context, e.message);
    } catch (_) {
      if (context.mounted) showAppToast(context, 'Не удалось прочитать файл');
    }
  }

  Future<void> _wipeAll(BuildContext context, AppStateProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Точно стереть все данные дневника?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Стереть')),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.wipeAll();
      if (context.mounted) showAppToast(context, 'Дневник очищен');
    }
  }
}
