import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/viewmodels/TodoViewModel.dart';

void main() {
  group('TodoViewModel Test', () {
    test('addTodo çağrıldığında listeye tablo eklenmeli', () {
      //arange
      final viewModel = TodoViewModel();
      //act
      viewModel.addTodo(title: 'Test Başlık', description: 'Test Açıklama');
      //assert
      expect(viewModel.todos.length, 1);
    });

    test('removeTodo çağrıldığında todo listeden silinmeli', () {
      //arange
      final viewModel = TodoViewModel();
      viewModel.addTodo(title: 'Test Başlık', description: 'Test Açıklama');
      final addedTodoId = viewModel.todos.first.id;

      //act
      viewModel.removeTodo(addedTodoId);

      //assert
      expect(viewModel.todos.isEmpty, true);
    });

    test('toggleTodo çağrıldığında isCompleted değeri değişmeli', () {
      //arrange
      final viewModel = TodoViewModel();
      viewModel.addTodo(title: 'Test Başlık', description: 'Test Açıklama');

      final todo = viewModel.todos.first;
      final todoId = todo.id;

      //act
      viewModel.toggleTodo(todoId);

      //assert
      expect(viewModel.todos.first.isCompleted, true);
    });
  });
}
