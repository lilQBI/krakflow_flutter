class Task {
  final String todo;
  final String deadline;
  bool done;
  final String priority;

  Task({
    required this.todo,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(todo: "Projekt Flutter", deadline: "jutro", done: false, priority: "wysoki"),
    Task(todo: "Oddać raport", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(todo: "Powtórzyć widgety", deadline: "w piątek", done: false, priority: "średni"),
    Task(todo: "Notatki do kolokwium", deadline: "w weekend", done: false, priority: "niski"),
  ];
}