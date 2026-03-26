import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  List<Task> tasks = [
    Task(title: "Przygotować prezentację", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Oddać raport", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(title: "Powtórzyć widgety", deadline: "w piątek", done: false, priority: "średni"),
    Task(title: "Notatki do kolokwium", deadline: "w weekend", done: false, priority: "niski"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
          ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś: ${tasks.length} zadania",
              style: TextStyle(
                fontSize: 32,
              )
              ),
              SizedBox(height: 16),
              Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                      icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Task{
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({required this.title,
        required this.deadline,
        required this.done,
        required this.priority,
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(subtitle),
      ),
    );
  }
}