import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/dashboard/widgets/month_selector.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/salary_calculation_card.dart';
import 'widgets/advance_list.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Takvim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              MonthSelector(
                currentMonth: viewModel.currentMonth,
                onPreviousMonth: viewModel.goToPreviousMonth,
                onNextMonth: viewModel.goToNextMonth,
              ),
              const SizedBox(height: 24),

              const CalendarGrid(),
              const SizedBox(height: 24),

              SalaryCalculationCard(
                viewModel: viewModel,
                currentMonth: viewModel.currentMonth,
              ),
              const SizedBox(height: 24),

              AdvanceList(
                viewModel: viewModel,
                currentMonth: viewModel.currentMonth,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}