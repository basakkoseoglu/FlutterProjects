import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/calendar/widgets/day_detail_bottom_sheet.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonth = viewModel.currentMonth;

    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeekdayHeaders(isDark),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (weekdayOfFirstDay - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay - 1) {
                return const SizedBox.shrink();
              }

              final day = index - (weekdayOfFirstDay - 1) + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final workType = viewModel.getWorkTypeForDate(date);
              final isToday = _isToday(date);

              return GestureDetector(
                onTap: () => DayDetailBottomSheet.show(context, date),
                child: _buildDayCell(day, workType, isToday, isDark),
              );
            },
          ),

          const SizedBox(height: 16),

          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(bool isDark) {
    const weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int day, WorkType? workType, bool isToday, bool isDark) {
    final color = _getColorForWorkType(workType);
    final hasWork = workType != null;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: hasWork
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: hasWork
                    ? Colors.white
                    : (isDark ? AppColors.darkSubText : AppColors.lightText),
              ),
            ),
          ),
          if (isToday)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem('Tam Gün', AppColors.success, Icons.check_circle, isDark),
        _legendItem('Yarım Gün', AppColors.warning, Icons.schedule, isDark),
        _legendItem('İzin', AppColors.danger, Icons.event_busy, isDark),
      ],
    );
  }

  Widget _legendItem(String label, Color color, IconData icon, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Color _getColorForWorkType(WorkType? type) {
    switch (type) {
      case WorkType.fullDay:
        return AppColors.success;
      case WorkType.halfDay:
        return AppColors.warning;
      case WorkType.leave:
        return AppColors.danger;
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }
}