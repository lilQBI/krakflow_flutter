import 'package:flutter/material.dart';
import 'task_repository.dart';
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                itemCount: TaskRepository.tasks.length,
                itemBuilder: (context, index) {
                  final task = TaskRepository.tasks[index];
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
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}