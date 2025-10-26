import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const TaskItem({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isDone == 1;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: IconButton(
          icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
          onPressed: onToggleDone,
        ),
        title: Text(
          task.title,
          style: TextStyle(decoration: done ? TextDecoration.lineThrough : TextDecoration.none),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 6),
            Text(
              'Created: ${task.createdAt}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }
}
