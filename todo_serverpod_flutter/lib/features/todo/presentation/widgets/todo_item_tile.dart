import 'package:flutter/material.dart';
import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../../../../core/utils/date_time_formatter.dart';

class TodoItemTile extends StatelessWidget {
  const TodoItemTile({
    super.key,
    required this.todo,
    required this.isBusy,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final bool isBusy;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dueLabel = todo.dueDate == null
        ? '期限なし'
        : formatTodoDateTime(todo.dueDate);
    final updatedLabel = formatTodoDateTime(todo.updatedAt);

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: isBusy
              ? null
              : (value) {
                  if (value != null) onToggleDone(value);
                },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((todo.description ?? '').isNotEmpty) Text(todo.description!),
            Text('期限: $dueLabel'),
            Text('更新: $updatedLabel'),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: '編集',
              onPressed: isBusy ? null : onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: '削除',
              onPressed: isBusy ? null : onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
