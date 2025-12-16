import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/viewmodels/TodoViewModel.dart';

class AddTodoDialog extends StatelessWidget {
  AddTodoDialog({super.key});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(child: const Text('Yeni Todo Ekle', style: TextStyle(fontWeight: FontWeight.bold),)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
                alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('İptal',style: TextStyle(color: Colors.black54),),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
          ),
          onPressed: () {
            context.read<TodoViewModel>().addTodo(
              title: titleController.text,
              description: descriptionController.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Ekle',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
