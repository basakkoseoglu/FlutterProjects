import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/viewmodels/history/history_viewmodel.dart';
import 'package:workdayapp/views/history/widgets/common_widgets.dart';

class MonthCard extends StatelessWidget {
  final DateTime month;
  final AttendanceViewModel attendanceVM;
  final HistoryViewModel historyVM;
  final int maxScore;
  final bool isDark;

  const MonthCard({
    super.key,
    required this.month,
    required this.attendanceVM,
    required this.historyVM,
    required this.maxScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final netSalary = attendanceVM.calculateNetSalary(month.month, month.year);
    final score = attendanceVM.getWorkScore(month.month, month.year);

    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            historyVM.formatMonth(month),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Net Maaş',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${netSalary.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              summaryChip(
                color: AppColors.success,
                label: 'Tam',
                count: attendanceVM.getFullDayCount(month.month, month.year),
              ),
              const SizedBox(width: 6),
              summaryChip(
                color: AppColors.warning,
                label: 'Yarım',
                count: attendanceVM.getHalfDayCount(month.month, month.year),
              ),
              const SizedBox(width: 6),
              summaryChip(
                color: AppColors.danger,
                label: 'İzin',
                count: attendanceVM.getLeaveCount(month.month, month.year),
              ),
            ],
          ),
          const SizedBox(height: 12),
          workProgressBar(
            score: score,
            maxScore: maxScore,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}