import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../todo/todo_query.dart';

class TodoRestRoute extends Route {
  static const _idParam = IntPathParam(#id);

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return Response.notFound();
  }

  @override
  void injectIn(RelicRouter router) {
    router
      ..get('/', _list)
      ..get('/:id', _getById)
      ..post('/', _create)
      ..patch('/:id', _patch)
      ..delete('/:id', _delete);
  }

  Future<Result> _getById(Request request) async {
    final session = await request.session;
    final id = request.pathParameters.get(_idParam);
    final result = await Todo.db.findById(session, id);
    if (result == null) {
      throw NotFoundException();
    }
    final responseBody = Body.fromString(
      jsonEncode(result.toJson()),
      mimeType: MimeType.json,
    );
    return Response.ok(body: responseBody);
  }

  Future<Result> _list(Request request) async {
    final session = await request.session;
    final sortBy = request.queryParameters.raw['sortBy'] ?? 'createdAt';
    final descending = TodoQuery.parseOrder(
      request.queryParameters.raw['order'] ?? 'asc',
    );
    final result = await TodoQuery.findTodosSorted(
      session,
      sortBy: sortBy,
      descending: descending,
    );
    final responseBody = Body.fromString(
      jsonEncode(result.map((todo) => todo.toJson()).toList()),
      mimeType: MimeType.json,
    );
    return Response.ok(body: responseBody);
  }

  Future<Result> _create(Request request) async {
    final session = await request.session;
    final requestBody = await request.readAsString();
    final data = jsonDecode(requestBody) as Map<String, dynamic>;
    final todo = Todo.fromJson(data);
    final result = await Todo.db.insertRow(session, todo);
    final responseBody = Body.fromString(
      jsonEncode(result.toJson()),
      mimeType: MimeType.json,
    );
    return Response.ok(body: responseBody);
  }

  Future<Result> _patch(Request request) async {
    final session = await request.session;
    final id = request.pathParameters.get(_idParam);
    final existing = await Todo.db.findById(session, id);
    if (existing == null) {
      throw NotFoundException();
    }

    final requestBody = await request.readAsString();
    final data = jsonDecode(requestBody);
    if (data is! Map<String, dynamic>) {
      throw ValidationException();
    }

    final merged = Map<String, dynamic>.from(existing.toJson())..addAll(data);
    merged['id'] = id;
    merged['createdAt'] = existing.createdAt.toJson();

    final updatedTodo = Todo.fromJson(merged);
    final result = await Todo.db.updateRow(session, updatedTodo);
    final responseBody = Body.fromString(
      jsonEncode(result.toJson()),
      mimeType: MimeType.json,
    );

    return Response.ok(body: responseBody);
  }

  Future<Result> _delete(Request request) async {
    final session = await request.session;
    final id = request.pathParameters.get(_idParam);
    final result = await Todo.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    if (result.isEmpty) {
      throw NotFoundException();
    }
    return Response.noContent();
  }
}
