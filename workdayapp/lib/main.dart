import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/theme/app_theme.dart';
import 'package:workdayapp/viewmodels/attendance_viewmodel.dart';
import 'package:workdayapp/viewmodels/theme_viewmodel.dart';
import 'package:workdayapp/views/main/main_view.dart';

void main()  {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(), 
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceViewModel()..loadAttendances(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: context.watch<ThemeViewModel>().themeMode,
  home: const MainView(),
);

  }
}