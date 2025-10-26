import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;
  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final db = DatabaseHelper.instance;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _nowTimestamp() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (widget.task == null) {
      final task = Task(
        title: title,
        description: desc,
        isDone: 0,
        createdAt: _nowTimestamp(),
      );
      await db.insertTask(task);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task ditambahkan')),
        );
      }
    } else {
      final updated = Task(
        id: widget.task!.id,
        title: title,
        description: desc,
        isDone: widget.task!.isDone,
        createdAt: widget.task!.createdAt,
      );
      await db.updateTask(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task diperbarui')),
        );
      }
    }

    setState(() => saving = false);
    Navigator.of(context).pop(true); // notify change
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Tambah Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
