import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/views/attendance/daily_attendance_view.dart';
import 'package:workdayapp/views/calendar/calendar_view.dart';
import 'package:workdayapp/views/dashboard/dashboard_view.dart';
import 'package:workdayapp/views/profile/profile_view.dart';

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
    ProfileView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),),
      bottomNavigationBar: BottomNavigationBar( 
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
  selectedItemColor: AppColors.primary,
  unselectedItemColor: Colors.grey,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Anasayfa',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: 'Takvim',
    ),
     BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ],
),
floatingActionButton: FloatingActionButton(
  backgroundColor: AppColors.primary,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<AttendanceViewModel>(context, listen: false),
          child: DailyAttendanceView(initialDate: DateTime.now()),
        ),
      ),
    );
  },
  child: const Icon(Icons.add,color: Colors.white,),
),
    );
  }
}