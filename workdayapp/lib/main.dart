import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/theme/app_theme.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';
import 'package:workdayapp/viewmodels/theme_viewmodel.dart';
import 'package:workdayapp/views/main/main_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(
          create: (_) {
            final vm = AttendanceViewModel();
            vm.loadAttendances();
            vm.loadSalarySettings();
            vm.loadAdvances();
            return vm;
          },
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
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeViewModel>().themeMode,
      home: const MainView(),
    );
  }
}
