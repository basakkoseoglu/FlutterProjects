import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/viewmodels/TodoViewModel.dart';
import 'package:todoapp/views/TodoView.dart';

void main() { 
  runApp(ChangeNotifierProvider(create:  (_) => TodoViewModel(),
  child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      home: ToDoView(),
    ) ;
  }
}