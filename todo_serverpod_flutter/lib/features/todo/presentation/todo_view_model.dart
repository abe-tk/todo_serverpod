import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:todo_serverpod_client/todo_serverpod_client.dart';

import '../data/todo_repository.dart';
import '../domain/todo_sort.dart';

class TodoViewModel extends ChangeNotifier {
  TodoViewModel({required TodoRepository repository}) : _repository = repository;

  final TodoRepository _repository;

  final List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;

  TodoSortField _sortField = TodoSortField.createdAt;
  TodoSortOrder _sortOrder = TodoSortOrder.asc;

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  bool get isBusy => _isLoading || _isMutating;
  String? get errorMessage => _errorMessage;
  TodoSortField get sortField => _sortField;
  TodoSortOrder get sortOrder => _sortOrder;

  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _repository.fetchTodos(
        sortField: _sortField,
        sortOrder: _sortOrder,
      );
      _todos
        ..clear()
        ..addAll(items);
    } catch (error) {
      _errorMessage = _readableError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      _errorMessage = 'タイトルを入力してください。';
      notifyListeners();
      return false;
    }

    return _runMutation(() async {
      await _repository.addTodo(
        title: normalizedTitle,
        description: _normalizeNullableText(description),
        dueDate: dueDate,
      );
      await loadTodos();
    });
  }

  Future<bool> toggleDone(Todo todo, bool done) {
    return _runMutation(() async {
      await _repository.updateTodo(todo.copyWith(isDone: done));
      await loadTodos();
    });
  }

  Future<bool> editTodo({
    required Todo todo,
    required String title,
    String? description,
    DateTime? dueDate,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      _errorMessage = 'タイトルを入力してください。';
      notifyListeners();
      return Future.value(false);
    }

    return _runMutation(() async {
      await _repository.updateTodo(
        todo.copyWith(
          title: normalizedTitle,
          description: _normalizeNullableText(description),
          dueDate: dueDate,
        ),
      );
      await loadTodos();
    });
  }

  Future<bool> deleteTodo(Todo todo) {
    final id = todo.id;
    if (id == null) {
      _errorMessage = 'ID がない TODO は削除できません。';
      notifyListeners();
      return Future.value(false);
    }

    return _runMutation(() async {
      await _repository.deleteTodo(id);
      await loadTodos();
    });
  }

  Future<void> updateSort({
    TodoSortField? sortField,
    TodoSortOrder? sortOrder,
  }) async {
    final nextField = sortField ?? _sortField;
    final nextOrder = sortOrder ?? _sortOrder;
    final changed = nextField != _sortField || nextOrder != _sortOrder;
    if (!changed) return;

    _sortField = nextField;
    _sortOrder = nextOrder;
    await loadTodos();
  }

  Future<bool> _runMutation(Future<void> Function() task) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await task();
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      notifyListeners();
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  String? _normalizeNullableText(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _readableError(Object error) {
    if (error is ValidationException) return error.message;
    if (error is NotFoundException) return error.message;
    return error.toString();
  }
}
