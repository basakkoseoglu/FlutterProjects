import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/attendance/widgets/date_selector_card.dart';
import 'package:workdayapp/views/attendance/widgets/delete_button.dart';
import 'package:workdayapp/views/attendance/widgets/save_button.dart';
import 'package:workdayapp/views/attendance/widgets/work_type_selector_card.dart';

class DailyAttendanceView extends StatelessWidget {
  final DateTime? initialDate;

  const DailyAttendanceView({super.key, this.initialDate});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

    if (initialDate != null && !_isSameDay(viewModel.selectedDate, initialDate!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.selectDate(initialDate!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Günlük Kayıt',
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
              DateSelectorCard(
                selectedDate: viewModel.selectedDate,
                onDateSelected: viewModel.selectDate,
              ),
              const SizedBox(height: 24),

              WorkTypeSelectorCard(
                selectedWorkType: viewModel.selectedWorkType,
                onWorkTypeSelected: viewModel.selectWorkType,
              ),
              const SizedBox(height: 24),

              SaveButton(
                isEnabled: viewModel.selectedWorkType != null,
                onPressed: () => _handleSave(context, viewModel),
              ),

              if (viewModel.selectedWorkType != null) ...[
                const SizedBox(height: 12),
                DeleteButton(
                  onConfirmedDelete: () => _handleDelete(context, viewModel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    AttendanceViewModel viewModel,
  ) async {
    await viewModel.saveAttendance();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kayıt başarıyla eklendi'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    AttendanceViewModel viewModel,
  ) async {
    await viewModel.deleteAttendanceForSelectedDate();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kayıt silindi'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}