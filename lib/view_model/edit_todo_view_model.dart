import 'package:flutter/foundation.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:intl/intl.dart';

class EditTodoViewState {
  EditTodoViewState({
    required this.title,
    required this.estimatedHours,
    required this.deadline,
  });

  final String title;
  final double estimatedHours;
  final DateTime deadline;

  EditTodoViewState copyWith({
    String? title,
    double? estimatedHours,
    DateTime? deadline,
  }) {
    return EditTodoViewState(
      title: title ?? this.title,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
    );
  }

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);
}

class EditTodoViewModel extends ValueNotifier<EditTodoViewState> {
  EditTodoViewModel(this._model, Todo todo)
      : _todoId = todo.id,
        super(EditTodoViewState(
          title: todo.title,
          estimatedHours: todo.estimatedHours,
          deadline: todo.deadline,
        ));

  final TodoModel _model;
  final String _todoId;

  void updateTitle(String title) {
    value = value.copyWith(title: title);
  }

  void updateEstimatedHours(double hours) {
    value = value.copyWith(estimatedHours: hours);
  }

  void updateDeadline(DateTime deadline) {
    value = value.copyWith(deadline: deadline);
  }

  void save() {
    if (value.title.trim().isEmpty) return;

    _model.updateTodo(
      _todoId,
      title: value.title,
      estimatedHours: value.estimatedHours,
      deadline: value.deadline,
    );
  }

  bool get isValid => value.title.trim().isNotEmpty;
}
