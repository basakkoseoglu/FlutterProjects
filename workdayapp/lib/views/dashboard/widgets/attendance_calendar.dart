import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'calendar_legend.dart';

/// Aylık puantaj takvimi widget'ı
class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final currentMonth = viewModel.currentMonth;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          _buildHeader(isDark),
          const SizedBox(height: 16),

          // Hafta günleri başlıkları
          _buildWeekdayHeaders(isDark),
          const SizedBox(height: 8),

          // Takvim grid
          _buildCalendarGrid(
            viewModel,
            currentMonth,
            daysInMonth,
            weekdayOfFirstDay,
            isDark,
          ),

          const SizedBox(height: 16),

          // Renk açıklamaları
          const CalendarLegend(),
        ],
      ),
    );
  }

  /// Kart başlığı
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Takvim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  /// Hafta günleri başlıkları
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

  /// Takvim grid yapısı
  Widget _buildCalendarGrid(
    AttendanceViewModel viewModel,
    DateTime currentMonth,
    int daysInMonth,
    int weekdayOfFirstDay,
    bool isDark,
  ) {
    return GridView.builder(
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
        // Ayın başlangıcından önceki boş hücreler
        if (index < weekdayOfFirstDay - 1) {
          return const SizedBox.shrink();
        }

        final day = index - (weekdayOfFirstDay - 1) + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final workType = viewModel.getWorkTypeForDate(date);
        final isToday = _isToday(date);

        return _buildDayCell(day, workType, isToday, isDark);
      },
    );
  }

  /// Tek bir gün hücresi
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
          // Gün numarası
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
          // Bugün işareti
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

  /// Bugün mü kontrol et
  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Çalışma tipine göre renk döndür
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