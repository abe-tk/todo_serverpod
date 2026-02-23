import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_formatter.dart';

class TodoCreateForm extends StatelessWidget {
  const TodoCreateForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.dueDate,
    required this.isBusy,
    required this.onPickDueDate,
    required this.onClearDueDate,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? dueDate;
  final bool isBusy;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新規TODO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              enabled: !isBusy,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              enabled: !isBusy,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: isBusy ? null : onPickDueDate,
                  child: const Text('期限を選択'),
                ),
                if (dueDate != null)
                  Text('期限: ${formatTodoDateTime(dueDate)}')
                else
                  const Text('期限なし'),
                if (dueDate != null)
                  TextButton(
                    onPressed: isBusy ? null : onClearDueDate,
                    child: const Text('クリア'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isBusy ? null : onSubmit,
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
