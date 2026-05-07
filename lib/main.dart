import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'services/task_api_service.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KrakFlow',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    done: false,
                    priority: "brak",
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}
class EditTaskScreen extends StatelessWidget {
  final Task task;
  final TextEditingController titleController;
  final TextEditingController deadlineController;

  EditTaskScreen({super.key, required this.task})
      : titleController = TextEditingController(text: task.title),
        deadlineController = TextEditingController(text: task.deadline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edytuj")),
      body: Column(
        children: [
          TextField(controller: titleController),
          TextField(controller: deadlineController),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, Task(
                title: titleController.text,
                deadline: deadlineController.text,
                done: task.done,
                priority: task.priority,
              ));
            },
            child: Text("Zapisz"),
          ),
        ],
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";
  @override
  Widget build(BuildContext context) {

    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Potwierdzenie"),
                    content: Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            TaskRepository.tasks.clear();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Wyczyszczono listę zadań")),
                          );
                        },
                        child: Text("Usuń", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masz dziś: ${TaskRepository.tasks.length} zadania",
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 16),

            FilterBar(
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: ValueKey(task.title + task.deadline),
                    direction: DismissDirection.endToStart,

                    onDismissed: (direction) {
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Zadanie '${task.title}' zostało usunięte"),
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: "OK",
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: TaskCard(
                    title: task.title,
                    subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                    done: task.done,
                    onChanged: (bool? value){
                      setState(() {
                        task.done = value!;
                      });
                    },
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (updatedTask != null) {
                        setState(() {
                          int originalIndex = TaskRepository.tasks.indexOf(task);
                          TaskRepository.tasks[originalIndex] = updatedTask;
                        });
                      }
                    },
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  FilterBar({required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => onFilterChanged("wszystkie"),
          child: Text("Wszystkie", style: TextStyle(color: selectedFilter == "wszystkie" ? Colors.red : Colors.grey)),
        ),
        TextButton(
          onPressed: () => onFilterChanged("do zrobienia"),
          child: Text("Do zrobienia", style: TextStyle(color: selectedFilter == "do zrobienia" ? Colors.red : Colors.grey)),
        ),
        TextButton(
          onPressed: () => onFilterChanged("wykonane"),
          child: Text("Wykonane", style: TextStyle(color: selectedFilter == "wykonane" ? Colors.red : Colors.grey)),
        ),
      ],
    );
  }
}
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasksFuture;
  @override
  void initState() {
    super.initState();
    tasksFuture = TaskApiService.fetchTasks();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
          },
        );
      },
    );
  }
}