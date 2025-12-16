import 'package:flutter/material.dart';
import 'package:todoapp/models/TodoModel.dart';

class TodoViewModel extends ChangeNotifier {
  final List<ToDoModel> _todos = [];

  List<ToDoModel> get todos => List.unmodifiable(_todos);

  void addTodo({
    required String title,
    required String description,
  }) {
    final newTodo = ToDoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
    );

    _todos.add(newTodo);
    notifyListeners();
  }

    void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index=_todos.indexWhere((todo) => todo.id == id);
    if(index!=-1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
    }
    
  }
}