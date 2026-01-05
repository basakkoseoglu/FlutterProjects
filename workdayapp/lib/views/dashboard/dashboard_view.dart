import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/services/pdf_report_service.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/dashboard/widgets/attendance_calendar.dart';
import 'package:workdayapp/views/dashboard/widgets/month_selector.dart';
import 'package:workdayapp/views/dashboard/widgets/monthly_summary_card.dart';
import 'package:workdayapp/views/dashboard/widgets/today_status_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

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

              MonthSelector(
                currentMonth: viewModel.currentMonth,
                onPreviousMonth: viewModel.goToPreviousMonth,
                onNextMonth: viewModel.goToNextMonth,
              ),
              const SizedBox(height: 12),

              MonthlySummaryCard(
                fullDay: viewModel.currentMonthFullDayCount,
                halfDay: viewModel.currentMonthHalfDayCount,
                leave: viewModel.currentMonthLeaveCount,
              ),
              const SizedBox(height: 24),

              _buildPdfButton(context),
              const SizedBox(height: 16),

              const AttendanceCalendar(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
        onPressed: () => _generatePdf(context),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final viewModel = context.read<AttendanceViewModel>();
    final pdfService = PdfReportService();

    await pdfService.generateMonthlyReport(
      attendances: viewModel.attendanceDates,
      month: viewModel.currentMonth.month,
      year: viewModel.currentMonth.year,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF rapor oluşturuldu')),
      );
    }
  }
}