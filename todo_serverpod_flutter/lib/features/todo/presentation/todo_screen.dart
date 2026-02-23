import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../domain/todo_sort.dart';
import 'todo_view_model.dart';
import 'widgets/todo_create_form.dart';
import 'widgets/todo_edit_dialog.dart';
import 'widgets/todo_item_tile.dart';

class TodoFeatureScreen extends StatefulWidget {
  const TodoFeatureScreen({super.key});

  @override
  State<TodoFeatureScreen> createState() => _TodoFeatureScreenState();
}

class _TodoFeatureScreenState extends State<TodoFeatureScreen> {
  final _newTitleController = TextEditingController();
  final _newDescriptionController = TextEditingController();
  DateTime? _newDueDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().loadTodos();
    });
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _newDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final viewModel = context.read<TodoViewModel>();
    final ok = await viewModel.addTodo(
      title: _newTitleController.text,
      description: _newDescriptionController.text,
      dueDate: _newDueDate,
    );

    if (!mounted) return;
    if (ok) {
      _newTitleController.clear();
      _newDescriptionController.clear();
      setState(() {
        _newDueDate = null;
      });
      return;
    }

    final message = viewModel.errorMessage;
    if (message != null) _showSnackBar(message);
  }

  Future<void> _editTodo(Todo todo) async {
    final viewModel = context.read<TodoViewModel>();
    final result = await showTodoEditDialog(context, todo: todo);
    if (result == null) return;

    final ok = await viewModel.editTodo(
      todo: todo,
      title: result.title,
      description: result.description,
      dueDate: result.dueDate,
    );

    if (!mounted || ok) return;
    final message = viewModel.errorMessage;
    if (message != null) _showSnackBar(message);
  }

  Future<void> _deleteTodo(Todo todo) async {
    final viewModel = context.read<TodoViewModel>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${todo.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await viewModel.deleteTodo(todo);
    if (!mounted || ok) return;

    final message = viewModel.errorMessage;
    if (message != null) _showSnackBar(message);
  }

  Future<void> _pickNewDueDate() async {
    final now = DateTime.now();
    final initial = _newDueDate ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: initial,
    );
    if (date == null || !mounted) return;
    setState(() {
      _newDueDate = DateTime(date.year, date.month, date.day);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TodoViewModel>();

    return RefreshIndicator(
      onRefresh: () => context.read<TodoViewModel>().loadTodos(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SortRow(
            sortField: viewModel.sortField,
            sortOrder: viewModel.sortOrder,
            disabled: viewModel.isBusy,
            onSortFieldChanged: (value) {
              context.read<TodoViewModel>().updateSort(sortField: value);
            },
            onSortOrderChanged: (value) {
              context.read<TodoViewModel>().updateSort(sortOrder: value);
            },
          ),
          const SizedBox(height: 12),
          TodoCreateForm(
            titleController: _newTitleController,
            descriptionController: _newDescriptionController,
            dueDate: _newDueDate,
            isBusy: viewModel.isBusy,
            onPickDueDate: _pickNewDueDate,
            onClearDueDate: () {
              setState(() {
                _newDueDate = null;
              });
            },
            onSubmit: _addTodo,
          ),
          const SizedBox(height: 12),
          if (viewModel.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (viewModel.errorMessage != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(viewModel.errorMessage!),
              ),
            )
          else if (viewModel.todos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('TODO がまだありません。'),
              ),
            )
          else
            ...viewModel.todos.map(
              (todo) => TodoItemTile(
                todo: todo,
                isBusy: viewModel.isBusy,
                onToggleDone: (value) {
                  context.read<TodoViewModel>().toggleDone(todo, value);
                },
                onEdit: () => _editTodo(todo),
                onDelete: () => _deleteTodo(todo),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.sortField,
    required this.sortOrder,
    required this.disabled,
    required this.onSortFieldChanged,
    required this.onSortOrderChanged,
  });

  final TodoSortField sortField;
  final TodoSortOrder sortOrder;
  final bool disabled;
  final ValueChanged<TodoSortField> onSortFieldChanged;
  final ValueChanged<TodoSortOrder> onSortOrderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'sortBy',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TodoSortField>(
                isExpanded: true,
                value: sortField,
                items: TodoSortField.values
                    .map(
                      (field) => DropdownMenuItem<TodoSortField>(
                        value: field,
                        child: Text(field.label),
                      ),
                    )
                    .toList(),
                onChanged: disabled
                    ? null
                    : (value) {
                        if (value != null) onSortFieldChanged(value);
                      },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'order',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TodoSortOrder>(
                isExpanded: true,
                value: sortOrder,
                items: TodoSortOrder.values
                    .map(
                      (order) => DropdownMenuItem<TodoSortOrder>(
                        value: order,
                        child: Text(order.label),
                      ),
                    )
                    .toList(),
                onChanged: disabled
                    ? null
                    : (value) {
                        if (value != null) onSortOrderChanged(value);
                      },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
