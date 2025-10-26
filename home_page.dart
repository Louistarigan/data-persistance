import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import 'add_edit_task_page.dart';
import '../widgets/task_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DatabaseHelper.instance;
  List<Task> tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => loading = true);
    tasks = await db.getAllTasks();
    setState(() => loading = false);
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final deletedId = task.id;
    await db.deleteTask(task.id!);
    await _loadTasks();
    final snack = SnackBar(
      content: Text('Task "${task.title}" dihapus'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          // restore by re-inserting
          if (deletedId != null) {
            final restored = Task(
              title: task.title,
              description: task.description,
              createdAt: task.createdAt,
              isDone: task.isDone,
            );
            await db.insertTask(restored);
            _loadTasks();
          }
        },
      ),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<void> _toggleDone(Task t) async {
    final updated = Task(
      id: t.id,
      title: t.title,
      description: t.description,
      createdAt: t.createdAt,
      isDone: t.isDone == 0 ? 1 : 0,
    );
    await db.updateTask(updated);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Belum ada tugas. Tekan + untuk menambah.'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id.toString()),
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                _deleteTask(context, task);
              },
              child: TaskItem(
                task: task,
                onEdit: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskPage(task: task),
                    ),
                  );
                  if (changed == true) _loadTasks();
                },
                onDelete: () => _deleteTask(context, task),
                onToggleDone: () => _toggleDone(task),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskPage()),
          );
          if (changed == true) _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
