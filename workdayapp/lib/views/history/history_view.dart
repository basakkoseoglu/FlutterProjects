import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/viewmodels/history/history_viewmodel.dart';
import 'package:workdayapp/viewmodels/theme/theme_viewmodel.dart';
import 'package:workdayapp/views/history/widgets/month_card.dart';
import 'package:workdayapp/views/history/widgets/summary_section.dart';
import 'package:workdayapp/views/history/widgets/theme_dialog.dart';
import 'package:workdayapp/views/history/widgets/common_widgets.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceVM = context.watch<AttendanceViewModel>();
    final historyVM = context.watch<HistoryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // çalışma skoru
    final scores = historyVM.months
        .map((m) => attendanceVM.getWorkScore(m.month, m.year))
        .toList();

    final maxScore = scores.every((s) => s == 0)
        ? 1
        : scores.reduce((a, b) => a > b ? a : b);

    // en yüksek maaş
    DateTime highestSalaryMonth = historyVM.months.first;
    double highestSalary = 0;

    for (final m in historyVM.months) {
      final salary = attendanceVM.calculateNetSalary(m.month, m.year);
      if (salary > highestSalary) {
        highestSalary = salary;
        highestSalaryMonth = m;
      }
    }

    //en yoğun ay
    final busiestMonth = historyVM.months.reduce((a, b) {
      final wa = attendanceVM.getWorkScore(a.month, a.year);
      final wb = attendanceVM.getWorkScore(b.month, b.year);
      return wa > wb ? a : b;
    });

    // son 3ay
    final totalSalary = historyVM.months.fold<double>(
      0,
      (sum, m) => sum + attendanceVM.calculateNetSalary(m.month, m.year),
    );

    final averageSalary = totalSalary / historyVM.months.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Geçmiş Aylar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeVM, _) {
              return IconButton(
                icon: Icon(
                  themeVM.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeVM.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  size: 22,
                ),
                onPressed: () => showThemeDialog(context, themeVM),
                tooltip: 'Tema',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 3aylık kartlar 
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: historyVM.months.length,
                itemBuilder: (context, index) {
                  final month = historyVM.months[index];
                  return MonthCard(
                    month: month,
                    attendanceVM: attendanceVM,
                    historyVM: historyVM,
                    maxScore: maxScore,
                    isDark: isDark,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                historyVM.getTrendText(scores),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withOpacity(0.9),
                ),
              ),
            ),

            const SizedBox(height: 14),

            
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  miniChip(
                    icon: Icons.trending_up,
                    text: 'En yüksek maaş: ${historyVM.formatMonth(highestSalaryMonth)}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  miniChip(
                    icon: Icons.calendar_today,
                    text: 'En yoğun ay: ${historyVM.formatMonth(busiestMonth)}',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SummarySection(
              totalSalary: totalSalary,
              averageSalary: averageSalary,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.insights,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        historyVM.getSummaryText(attendanceVM),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}