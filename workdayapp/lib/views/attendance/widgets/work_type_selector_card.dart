import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'work_type_tile.dart';

class WorkTypeSelectorCard extends StatelessWidget {
  final WorkType? selectedWorkType;
  final Function(WorkType) onWorkTypeSelected;

  const WorkTypeSelectorCard({
    super.key,
    required this.selectedWorkType,
    required this.onWorkTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Çalışma Türü',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          WorkTypeTile(
            title: 'Tam Gün',
            icon: Icons.check_circle,
            color: AppColors.success,
            selected: selectedWorkType == WorkType.fullDay,
            onTap: () => onWorkTypeSelected(WorkType.fullDay),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          WorkTypeTile(
            title: 'Yarım Gün',
            icon: Icons.schedule,
            color: AppColors.warning,
            selected: selectedWorkType == WorkType.halfDay,
            onTap: () => onWorkTypeSelected(WorkType.halfDay),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          WorkTypeTile(
            title: 'İzin',
            icon: Icons.event_busy,
            color: AppColors.danger,
            selected: selectedWorkType == WorkType.leave,
            onTap: () => onWorkTypeSelected(WorkType.leave),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}