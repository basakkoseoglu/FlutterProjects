import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/viewmodels/TodoViewModel.dart';
import 'package:todoapp/views/AddTodoDialog.dart';

class ToDoView extends StatelessWidget {
  const ToDoView({super.key});

  @override
  Widget build(BuildContext context) {
    final todoViewModel = context.watch<TodoViewModel>();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 207, 156),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 247, 207, 156),
        
        title:  Text('YAPILACAKLAR',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),

      body: todoViewModel.todos.isEmpty
          ? const Center(child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined,size: 100,color: Colors.white,),
              SizedBox(height: 20,),
              Text('Henüz bir planınız yok. \nOluşturmak için butona tıklayabilirsiniz.',style: TextStyle(fontSize: 18,color: Colors.white), textAlign: TextAlign.center,)
            ],
            
          ),) 
          : ListView.builder(
              itemCount: todoViewModel.todos.length,
              itemBuilder: (context, index) {
                final todo = todoViewModel.todos[index];
                return Dismissible(
                  key: Key(todo.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context.read<TodoViewModel>().removeTodo(todo.id);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[200],
                      border: Border(
                        bottom: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        todo.description,
                        style: TextStyle(
                          color: todo.isCompleted
                              ? Colors.grey.shade600
                              : Colors.black54,
                        ),
                      ),
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) {
                          context.read<TodoViewModel>().toggleTodo(todo.id);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 226, 188, 138),
        onPressed: () {
          showDialog(context: context, builder: (_) => AddTodoDialog());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
