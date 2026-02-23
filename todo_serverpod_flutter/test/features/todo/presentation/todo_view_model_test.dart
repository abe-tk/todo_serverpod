import 'package:flutter_test/flutter_test.dart';
import 'package:todo_serverpod_client/todo_serverpod_client.dart';
import 'package:todo_serverpod_flutter/features/todo/data/todo_repository.dart';
import 'package:todo_serverpod_flutter/features/todo/domain/todo_sort.dart';
import 'package:todo_serverpod_flutter/features/todo/presentation/todo_view_model.dart';

void main() {
  group('TodoViewModel', () {
    late _FakeTodoRepository repository;
    late TodoViewModel viewModel;

    setUp(() {
      repository = _FakeTodoRepository();
      viewModel = TodoViewModel(repository: repository);
    });

    test('loadTodos fetches data using default sort', () async {
      repository.nextTodos = [
        Todo(id: 1, title: 'A'),
      ];

      await viewModel.loadTodos();

      expect(viewModel.todos.length, 1);
      expect(viewModel.todos.first.title, 'A');
      expect(repository.lastSortField, TodoSortField.createdAt);
      expect(repository.lastSortOrder, TodoSortOrder.asc);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('updateSort changes sort and reloads', () async {
      await viewModel.updateSort(
        sortField: TodoSortField.dueDate,
        sortOrder: TodoSortOrder.desc,
      );

      expect(viewModel.sortField, TodoSortField.dueDate);
      expect(viewModel.sortOrder, TodoSortOrder.desc);
      expect(repository.lastSortField, TodoSortField.dueDate);
      expect(repository.lastSortOrder, TodoSortOrder.desc);
    });

    test('addTodo validates title locally', () async {
      final ok = await viewModel.addTodo(title: '   ');

      expect(ok, isFalse);
      expect(viewModel.errorMessage, 'タイトルを入力してください。');
      expect(repository.addCalls, 0);
    });

    test('toggleDone updates todo and refreshes list', () async {
      repository.nextTodos = [Todo(id: 1, title: 'Task', isDone: false)];
      final todo = Todo(id: 1, title: 'Task', isDone: false);

      final ok = await viewModel.toggleDone(todo, true);

      expect(ok, isTrue);
      expect(repository.updatedTodos.single.isDone, isTrue);
      expect(repository.fetchCalls, greaterThan(0));
    });

    test('deleteTodo handles missing id safely', () async {
      final ok = await viewModel.deleteTodo(Todo(title: 'No id'));

      expect(ok, isFalse);
      expect(viewModel.errorMessage, 'ID がない TODO は削除できません。');
      expect(repository.deleteCalls, 0);
    });

    test('maps ValidationException message on load error', () async {
      repository.fetchError = ValidationException(message: 'bad request');

      await viewModel.loadTodos();

      expect(viewModel.errorMessage, 'bad request');
      expect(viewModel.isLoading, isFalse);
    });
  });
}

class _FakeTodoRepository implements TodoRepository {
  List<Todo> nextTodos = [];
  Object? fetchError;
  int fetchCalls = 0;
  int addCalls = 0;
  int deleteCalls = 0;
  TodoSortField? lastSortField;
  TodoSortOrder? lastSortOrder;
  final List<Todo> updatedTodos = [];

  @override
  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    addCalls += 1;
  }

  @override
  Future<void> deleteTodo(int id) async {
    deleteCalls += 1;
  }

  @override
  Future<List<Todo>> fetchTodos({
    required TodoSortField sortField,
    required TodoSortOrder sortOrder,
  }) async {
    fetchCalls += 1;
    lastSortField = sortField;
    lastSortOrder = sortOrder;
    if (fetchError != null) throw fetchError!;
    return nextTodos;
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    updatedTodos.add(todo);
  }
}
