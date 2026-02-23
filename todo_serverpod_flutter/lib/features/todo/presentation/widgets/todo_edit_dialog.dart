import 'package:flutter/material.dart';
import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../../../../core/utils/date_time_formatter.dart';

class TodoEditResult {
  const TodoEditResult({
    required this.title,
    required this.description,
    required this.dueDate,
  });

  final String title;
  final String? description;
  final DateTime? dueDate;
}

Future<TodoEditResult?> showTodoEditDialog(
  BuildContext context, {
  required Todo todo,
}) {
  return showDialog<TodoEditResult>(
    context: context,
    builder: (context) => _TodoEditDialog(todo: todo),
  );
}

class _TodoEditDialog extends StatefulWidget {
  const _TodoEditDialog({required this.todo});

  final Todo todo;

  @override
  State<_TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends State<_TodoEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description ?? '',
    );
    _dueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: initial,
    );
    if (date == null) return;
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day);
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください。')),
      );
      return;
    }

    Navigator.pop(
      context,
      TodoEditResult(
        title: title,
        description: description.isEmpty ? null : description,
        dueDate: _dueDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('TODOを編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '説明'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _pickDueDate,
                  child: const Text('期限を選択'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dueDate == null ? '期限なし' : formatTodoDateTime(_dueDate),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
                child: const Text('期限をクリア'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
