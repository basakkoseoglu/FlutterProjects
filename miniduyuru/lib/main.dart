import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miniduyuru/firebase_options.dart';
import 'package:miniduyuru/viewmodels/admin_viewmodel.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/viewmodels/user_viewmodel.dart';
import 'package:miniduyuru/views/auth/splash_decider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashDecider(),
    );
  }
}
