import 'dart:async';
import 'package:arc_todo/storage/todo_storage.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.estimatedHours,
    required this.deadline,
  });

  final String id;
  final String title;
  bool isCompleted;
  final double estimatedHours;
  final DateTime deadline;

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);
}

class TodoModel {
  TodoModel(this._storage) {
    _todos.addAll(_storage.fetchAll());
    _todoController.add(_todos);
  }

  final TodoStorage _storage;
  final _todoController = StreamController<List<Todo>>.broadcast();
  final List<Todo> _todos = [];

  Stream<List<Todo>> get todoStream => _todoController.stream;

  void addTodo({
    required String title,
    required double estimatedHours,
    required DateTime deadline,
  }) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      estimatedHours: estimatedHours,
      deadline: deadline,
    );
    _storage.save(todo);
    _todos
      ..clear()
      ..addAll(_storage.fetchAll());
    _todoController.add(_todos);
  }

  void updateTodo(
    String id, {
    String? title,
    double? estimatedHours,
    DateTime? deadline,
  }) {
    final original =
        _storage.fetchAll().firstWhereOrNull((todo) => todo.id == id);
    if (original == null) {
      return;
    }

    final updatedTodo = Todo(
      id: id,
      title: title ?? original.title,
      isCompleted: original.isCompleted,
      estimatedHours: estimatedHours ?? original.estimatedHours,
      deadline: deadline ?? original.deadline,
    );

    _storage.save(updatedTodo);
    _todos[_todos.indexWhere((todo) => todo.id == id)] = updatedTodo;
    _todoController.add(_todos);
  }

  void deleteTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    _storage.delete(id);
    _todos.removeAt(index);
    _todoController.add(_todos);
  }

  void dispose() {
    _todoController.close();
  }
}
