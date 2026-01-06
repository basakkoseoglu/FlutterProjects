import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';

Widget summaryChip({
  required Color color,
  required String label,
  required int count,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      '$label: $count',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

Widget workProgressBar({
  required int score,
  required int maxScore,
  required bool isDark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LinearProgressIndicator(
        value: score / maxScore,
        minHeight: 8,
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
      ),
      const SizedBox(height: 4),
      Text(
        'Çalışma yoğunluğu',
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    ],
  );
}

Widget miniChip({
  required IconData icon,
  required String text,
  required bool isDark,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}