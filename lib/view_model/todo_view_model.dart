import 'package:flutter/foundation.dart';
import 'package:arc_todo/model/todo_model.dart';

class TodoViewState {
  TodoViewState({
    required this.todos,
  });

  final List<Todo> todos;

  TodoViewState copyWith({
    List<Todo>? todos,
  }) {
    return TodoViewState(
      todos: todos ?? this.todos,
    );
  }
}

class TodoViewModel extends ValueNotifier<TodoViewState> {
  TodoViewModel(this._model) : super(TodoViewState(todos: [])) {
    _model.todoStream.listen((todos) {
      value = value.copyWith(todos: todos);
    });
  }

  final TodoModel _model;

  void deleteTodo(String id) {
    _model.deleteTodo(id);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
