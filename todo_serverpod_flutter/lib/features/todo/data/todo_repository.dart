import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../domain/todo_sort.dart';

abstract class TodoRepository {
  Future<List<Todo>> fetchTodos({
    required TodoSortField sortField,
    required TodoSortOrder sortOrder,
  });

  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  });

  Future<void> updateTodo(Todo todo);

  Future<void> deleteTodo(int id);
}
