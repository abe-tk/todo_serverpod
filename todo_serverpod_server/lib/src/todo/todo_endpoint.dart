import '../generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'todo_query.dart';

class TodoEndpoint extends Endpoint {
  Future<Todo> getTodo(Session session, {required int id}) async {
    final result = await Todo.db.findById(session, id);
    if (result == null) {
      throw NotFoundException();
    }
    return result;
  }

  Future<List<Todo>> getTodos(
    Session session, {
    String sortBy = 'createdAt',
    String order = 'asc',
  }) async {
    final descending = TodoQuery.parseOrder(order);
    return TodoQuery.findTodosSorted(
      session,
      sortBy: sortBy,
      descending: descending,
    );
  }

  Future<void> addTodo(Session session, {required Todo todo}) async {
    await Todo.db.insertRow(session, todo);
  }

  Future<void> updateTodo(Session session, {required Todo todo}) async {
    if (todo.id == null) {
      throw ValidationException();
    }

    final existing = await Todo.db.findById(session, todo.id!);
    if (existing == null) {
      throw NotFoundException();
    }

    final merged = Map<String, dynamic>.from(existing.toJson())
      ..addAll(todo.toJson());
    merged['createdAt'] = existing.createdAt.toJson();

    final updatedTodo = Todo.fromJson(merged);
    await Todo.db.updateRow(session, updatedTodo);
  }

  Future<void> deleteTodo(Session session, {required int id}) async {
    final result = await Todo.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    if (result.isEmpty) {
      throw NotFoundException();
    }
  }
}
