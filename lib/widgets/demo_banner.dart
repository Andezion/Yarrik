import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE6FFF4D6), Color(0xBFFCE6AA)],
        ),
        border: Border.all(color: const Color(0xFFC8962D).withValues(alpha: 0.45)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const Text(
            '✦ Это демо-данные — чтобы показать интерфейс в деле. Начни с чистого листа или загрузи свою копию в настройках.',
            style: TextStyle(color: Color(0xFF7A5606), fontSize: 12.5),
          ),
          OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              foregroundColor: AppColors.text,
            ),
            child: const Text('Очистить демо', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
