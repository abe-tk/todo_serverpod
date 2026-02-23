import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../domain/todo_sort.dart';
import 'todo_repository.dart';

class ServerpodTodoRepository implements TodoRepository {
  ServerpodTodoRepository(this._client);

  final Client _client;

  @override
  Future<List<Todo>> fetchTodos({
    required TodoSortField sortField,
    required TodoSortOrder sortOrder,
  }) {
    return _client.todo.getTodos(
      sortBy: sortField.apiValue,
      order: sortOrder.apiValue,
    );
  }

  @override
  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) {
    return _client.todo.addTodo(
      todo: Todo(
        title: title,
        description: description,
        dueDate: dueDate,
      ),
    );
  }

  @override
  Future<void> updateTodo(Todo todo) {
    return _client.todo.updateTodo(todo: todo);
  }

  @override
  Future<void> deleteTodo(int id) {
    return _client.todo.deleteTodo(id: id);
  }
}
