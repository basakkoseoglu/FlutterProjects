import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/calendar/widgets/dialogs/add_advance_dialog.dart';
import 'package:workdayapp/views/calendar/widgets/dialogs/salary_settings_dialog.dart';


class SalaryCalculationCard extends StatelessWidget {
  final AttendanceViewModel viewModel;
  final DateTime currentMonth;

  const SalaryCalculationCard({
    super.key,
    required this.viewModel,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grossSalary = viewModel.currentMonthGrossSalary;
    final netSalary = viewModel.currentMonthNetSalary;
    final advance = viewModel.getMonthlyAdvance(
      currentMonth.month,
      currentMonth.year,
    );

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
          _buildHeader(context, isDark),
          const SizedBox(height: 16),

          _buildSalaryInfoRow(
            'Günlük Ücret',
            '${viewModel.salarySettings.dailyWage.toStringAsFixed(2)} ₺',
            Icons.calendar_today,
            AppColors.primary,
            isDark,
          ),
          const SizedBox(height: 8),

          if (advance > 0) ...[
            _buildSalaryInfoRow(
              'Avans',
              '- ${advance.toStringAsFixed(2)} ₺',
              Icons.money_off,
              AppColors.warning,
              isDark,
            ),
            const SizedBox(height: 4),
          ],

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => AddAdvanceDialog.show(context, viewModel),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Avans Ekle'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
              ),
            ),
          ),

          const Divider(height: 24),

          _buildSalaryInfoRow(
            'Brüt Maaş',
            '${grossSalary.toStringAsFixed(2)} ₺',
            Icons.attach_money,
            AppColors.success,
            isDark,
            isBold: true,
          ),
          const SizedBox(height: 8),

          _buildNetSalaryCard(netSalary),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Icons.payments,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Maaş Hesabı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => SalarySettingsDialog.show(context, viewModel),
          icon: const Icon(Icons.settings, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSalaryInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNetSalaryCard(double netSalary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success,
            AppColors.success.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Net Alacak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '${netSalary.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}