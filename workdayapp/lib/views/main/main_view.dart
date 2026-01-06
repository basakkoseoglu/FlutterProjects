import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/attendance/daily_attendance_view.dart';
import 'package:workdayapp/views/calendar/calendar_view.dart';
import 'package:workdayapp/views/dashboard/dashboard_view.dart';
import 'package:workdayapp/views/history/history_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    CalendarView(),
    HistoryView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Anasayfa',
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Takvim',
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Geçmiş',
                index: 2,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: Provider.of<AttendanceViewModel>(
                    context,
                    listen: false,
                  ),
                  child: DailyAttendanceView(initialDate: DateTime.now()),
                ),
              ),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
