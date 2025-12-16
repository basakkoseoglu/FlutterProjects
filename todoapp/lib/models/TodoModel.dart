class ToDoModel{
  final String id;
  final String title;
  final String description;
   bool isCompleted;

  ToDoModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}
