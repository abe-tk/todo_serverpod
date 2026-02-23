import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class TodoQuery {
  static final Map<String, OrderByBuilder<TodoTable>> _orderByMap = {
    'createdAt': (t) => t.createdAt,
    'updatedAt': (t) => t.updatedAt,
    'dueDate': (t) => t.dueDate,
  };

  static bool parseOrder(String order) {
    switch (order) {
      case 'asc':
        return false;
      case 'desc':
        return true;
      default:
        throw ValidationException();
    }
  }

  static Future<List<Todo>> findTodosSorted(
    Session session, {
    required String sortBy,
    required bool descending,
  }) {
    final orderBy = _orderByMap[sortBy];
    if (orderBy == null) {
      throw ValidationException();
    }
    return Todo.db.find(
      session,
      orderBy: orderBy,
      orderDescending: descending,
    );
  }
}
