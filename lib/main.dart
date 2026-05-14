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
      home: const HomeScreen(),
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
        title: const Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  todo: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: "brak",
                );
                Navigator.pop(context, newTask);
              },
              child: const Text("Zapisz"),
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
      : titleController = TextEditingController(text: task.todo),
        deadlineController = TextEditingController(text: task.deadline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj")),
      body: Column(
        children: [
          TextField(controller: titleController),
          TextField(controller: deadlineController),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, Task(
                todo: titleController.text,
                deadline: deadlineController.text,
                done: task.done,
                priority: task.priority,
              ));
            },
            child: const Text("Zapisz"),
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
  late Future<List<Task>> tasksFuture;
  List<Task>? localTasks;

  @override
  void initState() {
    super.initState();
    tasksFuture = TaskApiService.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (localTasks != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Potwierdzenie"),
                      content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Anuluj"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              localTasks!.clear();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Wyczyszczono listę zadań")),
                            );
                          },
                          child: const Text("Usuń", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting && localTasks == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && localTasks == null) {
            return Center(child: Text("Błąd: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.hasData || localTasks != null) {
            localTasks ??= snapshot.data!;

            List<Task> filteredTasks = localTasks!;
            if (selectedFilter == "wykonane") {
              filteredTasks = localTasks!.where((task) => task.done).toList();
            } else if (selectedFilter == "do zrobienia") {
              filteredTasks = localTasks!.where((task) => !task.done).toList();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Masz dziś: ${localTasks!.length} zadań",
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  FilterBar(
                    selectedFilter: selectedFilter,
                    onFilterChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];

                        return Dismissible(
                          key: ValueKey(task.todo + task.deadline),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              localTasks!.remove(task);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Zadanie '${task.todo}' zostało usunięte"),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: "OK",
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                          child: TaskCard(
                            todo: task.todo,
                            subtitle: "termin: ${task.deadline} | priorytet: ${task.priority}",
                            done: task.done,
                            onChanged: (bool? value) {
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
                                  int originalIndex = localTasks!.indexOf(task);
                                  localTasks![originalIndex] = updatedTask;
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
            );
          }
          return const Center(child: Text("Brak zadań do wyświetlenia"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
          if (newTask != null && localTasks != null) {
            setState(() {
              localTasks!.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String todo;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.todo,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          todo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBar({super.key, required this.selectedFilter, required this.onFilterChanged});

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