import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/models/advance.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';

class AdvanceList extends StatelessWidget {
  final AttendanceViewModel viewModel;
  final DateTime currentMonth;

  const AdvanceList({
    super.key,
    required this.viewModel,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advances = viewModel.getAdvancesForMonth(
      currentMonth.month,
      currentMonth.year,
    );

    if (advances.isEmpty) {
      return Text(
        'Bu ay avans yok',
        style: TextStyle(
          color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          fontSize: 13,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avanslar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        ...advances.map((advance) => _buildAdvanceItem(advance, isDark)),
      ],
    );
  }

  Widget _buildAdvanceItem(Advance advance, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.warning.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${advance.amount.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (advance.note != null && advance.note!.isNotEmpty)
                Text(
                  advance.note!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => viewModel.removeAdvance(advance),
          ),
        ],
      ),
    );
  }
}