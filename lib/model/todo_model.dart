import 'dart:async';
import 'package:todo_demoapp/storage/todo_storage.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:todo_demoapp/model/member.dart';

class DeadlineRestrictionException implements Exception {
  DeadlineRestrictionException(this.message);
  final String message;
}

class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.estimatedHours,
    required this.deadline,
    required this.assignee,
    required this.createdBy,
    this.isPublic = false,
  });

  final String id;
  final String title;
  bool isCompleted;
  final double estimatedHours;
  final DateTime deadline;
  final Member assignee;
  final Member createdBy;
  bool isPublic;

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);

  Todo copyWith({
    String? title,
    bool? isCompleted,
    double? estimatedHours,
    DateTime? deadline,
    Member? assignee,
    bool? isPublic,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
      assignee: assignee ?? this.assignee,
      createdBy: createdBy,
      isPublic: isPublic ?? this.isPublic,
    );
  }
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
    required Member assignee,
  }) {
    try {
      _validateDeadlineRestriction(estimatedHours, deadline);
    } on DeadlineRestrictionException {
      rethrow;
    }

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      estimatedHours: estimatedHours,
      deadline: deadline,
      assignee: assignee,
      createdBy: Member(id: '', name: '', icon: IconType.person),
      isPublic: false,
    );
    _storage.save(todo);
    _todos
      ..clear()
      ..addAll(_storage.fetchAll());
    _todoController.add(_todos);
  }

  void _validateDeadlineRestriction(
      double newTodoHours, DateTime newTodoDeadline) {
    // Check if deadline provides enough time for the task itself
    final hoursUntilDeadline =
        newTodoDeadline.difference(DateTime.now()).inHours;
    if (hoursUntilDeadline < newTodoHours) {
      throw DeadlineRestrictionException(
        'Not enough time to complete this task. Task needs $newTodoHours hours but only $hoursUntilDeadline hours available until deadline.',
      );
    }

    // Get all todos that need to be completed before or at this new deadline
    final todosBeforeDeadline = _todos
        .where((todo) => !todo.isCompleted)
        .where((todo) =>
            todo.deadline.isBefore(newTodoDeadline) ||
            todo.deadline.isAtSameMomentAs(newTodoDeadline))
        .toList();

    // Calculate total hours needed for existing todos
    final totalExistingHours = todosBeforeDeadline.fold<double>(
      0,
      (sum, todo) => sum + todo.estimatedHours,
    );

    // Check if there's enough time for both existing todos and new todo
    final totalRequiredHours = totalExistingHours + newTodoHours;
    if (totalRequiredHours > hoursUntilDeadline) {
      throw DeadlineRestrictionException(
        'Not enough time to complete this task. You already have $totalExistingHours hours of tasks before this deadline.',
      );
    }
  }

  void updateTodo(
    String id, {
    String? title,
    double? estimatedHours,
    DateTime? deadline,
    Member? assignee,
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
      assignee: assignee ?? original.assignee,
      createdBy: original.createdBy,
      isPublic: original.isPublic,
    );

    _storage.update(updatedTodo);
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

  void toggleTodoCompletion(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todo = _todos[index];
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      isCompleted: !todo.isCompleted,
      estimatedHours: todo.estimatedHours,
      deadline: todo.deadline,
      assignee: todo.assignee,
      createdBy: todo.createdBy,
      isPublic: todo.isPublic,
    );

    _storage.update(updatedTodo);
    _todos[index] = updatedTodo;
    _todoController.add(_todos);
  }

  void toggleTodoVisibility(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(isPublic: !todo.isPublic);

    _storage.update(updatedTodo);
    _todos[index] = updatedTodo;
    _todoController.add(_todos);
  }

  void updateTodoAssignee(String id, Member newAssignee) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(assignee: newAssignee);

    _storage.update(updatedTodo);
    _todos[index] = updatedTodo;
    _todoController.add(_todos);
  }

  void dispose() {
    _todoController.close();
  }
}
