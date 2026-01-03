import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/services/pdf_report_service.dart';
import 'package:workdayapp/viewmodels/attendance_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Puantajım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TodayStatusCard(status: viewModel.todayStatus),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: viewModel.goToPreviousMonth,
                  ),
                  Text(
                    '${viewModel.currentMonth.month}.${viewModel.currentMonth.year}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: viewModel.goToNextMonth,
                  ),
                ],
              ),

              MonthlySummaryCard(
                fullDay: viewModel.currentMonthFullDayCount,
                halfDay: viewModel.currentMonthHalfDayCount,
                leave: viewModel.currentMonthLeaveCount,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text(
                        'PDF Rapor Oluştur',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        _generatePdf(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                ],
              ),

              const SizedBox(height: 16),
              _AttendanceCalendar(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayStatusCard extends StatelessWidget {
  final String status;

  const TodayStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final hasRecord = status.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasRecord
              ? const [AppColors.primary, AppColors.primaryLight]
              : const [AppColors.inactiveSoft, AppColors.inactiveSoftLight],
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasRecord ? Icons.work : Icons.event_busy,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bugün', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                hasRecord ? status : 'Henüz kayıt yok',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthlySummaryCard extends StatelessWidget {
  final int fullDay;
  final int halfDay;
  final int leave;

  const MonthlySummaryCard({
    super.key,
    required this.fullDay,
    required this.halfDay,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                child: Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Aylık Özet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _summaryRow('Tam Gün', fullDay, AppColors.success, isDark),
          _summaryRow('Yarım Gün', halfDay, AppColors.warning, isDark),
          _summaryRow('İzin', leave, AppColors.danger, isDark),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, int value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCalendar extends StatelessWidget {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
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
          ),
          const SizedBox(height: 16),

          _buildWeekdayHeaders(isDark),
          const SizedBox(height: 8),

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

              return _buildDayCell(day, workType, isToday, isDark);
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
                decoration: BoxDecoration(
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

void _generatePdf(BuildContext context) async {
  final viewModel = context.read<AttendanceViewModel>();
  final pdfService = PdfReportService();

  await pdfService.generateMonthlyReport(
    attendances: viewModel.attendanceDates,
    month: viewModel.currentMonth.month,
    year: viewModel.currentMonth.year,
  );

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('PDF rapor oluşturuldu')));
}
