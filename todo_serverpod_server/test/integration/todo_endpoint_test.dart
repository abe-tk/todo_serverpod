import 'package:test/test.dart';
import 'package:todo_serverpod_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Todo endpoint', (sessionBuilder, endpoints) {
    test('when add todo then getTodo returns inserted item', () async {
      final now = DateTime.now().toUtc();
      await endpoints.todo.addTodo(
        sessionBuilder,
        todo: Todo(
          title: 'Buy milk',
          description: '2 bottles',
          isDone: false,
          dueDate: now.add(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final todos = await endpoints.todo.getTodos(
        sessionBuilder,
        sortBy: 'createdAt',
        order: 'asc',
      );
      expect(todos.length, 1);
      final inserted = todos.first;
      final fetched = await endpoints.todo.getTodo(sessionBuilder, id: inserted.id!);

      expect(fetched.title, 'Buy milk');
      expect(fetched.description, '2 bottles');
    });

    test('when sortBy dueDate desc then latest dueDate comes first', () async {
      final now = DateTime.now().toUtc();
      await endpoints.todo.addTodo(
        sessionBuilder,
        todo: Todo(
          title: 'First',
          dueDate: now.add(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await endpoints.todo.addTodo(
        sessionBuilder,
        todo: Todo(
          title: 'Second',
          dueDate: now.add(const Duration(days: 2)),
          createdAt: now.add(const Duration(seconds: 1)),
          updatedAt: now.add(const Duration(seconds: 1)),
        ),
      );

      final todos = await endpoints.todo.getTodos(
        sessionBuilder,
        sortBy: 'dueDate',
        order: 'desc',
      );

      expect(todos.length, 2);
      expect(todos.first.title, 'Second');
      expect(todos.last.title, 'First');
    });

    test('when updateTodo then createdAt is preserved', () async {
      final createdAt = DateTime.utc(2026, 2, 1);
      final updatedAt = DateTime.utc(2026, 2, 2);
      await endpoints.todo.addTodo(
        sessionBuilder,
        todo: Todo(
          title: 'Before update',
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );

      final todos = await endpoints.todo.getTodos(
        sessionBuilder,
        sortBy: 'createdAt',
        order: 'asc',
      );
      final target = todos.first;

      await endpoints.todo.updateTodo(
        sessionBuilder,
        todo: target.copyWith(
          title: 'After update',
          createdAt: DateTime.utc(2030, 1, 1), // should be ignored in endpoint
          updatedAt: DateTime.utc(2030, 1, 2),
        ),
      );

      final updated = await endpoints.todo.getTodo(sessionBuilder, id: target.id!);
      expect(updated.title, 'After update');
      expect(updated.createdAt, createdAt);
    });

    test('when deleteTodo then getTodo throws NotFoundException', () async {
      final now = DateTime.now().toUtc();
      await endpoints.todo.addTodo(
        sessionBuilder,
        todo: Todo(title: 'To delete', createdAt: now, updatedAt: now),
      );

      final todos = await endpoints.todo.getTodos(
        sessionBuilder,
        sortBy: 'createdAt',
        order: 'asc',
      );
      final id = todos.first.id!;

      await endpoints.todo.deleteTodo(sessionBuilder, id: id);

      expect(
        () => endpoints.todo.getTodo(sessionBuilder, id: id),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
