class Task {
  final int id;
  final String todo;
  final String deadline;
  bool done;
  final String priority;

  Task({
    required this.id,
    required this.todo,
    required this.deadline,
    required this.done,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "todo": todo,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map["id"],
      todo: map["todo"],
      deadline: map["deadline"],
      priority: map["priority"],
      done: map["done"],
    );
  }
}
/*
class TaskRepository {
  static List<Task> tasks = [
    Task(todo: "Projekt Flutter", deadline: "jutro", done: false, priority: "wysoki"),
    Task(todo: "Oddać raport", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(todo: "Powtórzyć widgety", deadline: "w piątek", done: false, priority: "średni"),
    Task(todo: "Notatki do kolokwium", deadline: "w weekend", done: false, priority: "niski"),
  ];
}
 */