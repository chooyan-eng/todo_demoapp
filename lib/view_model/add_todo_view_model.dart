import 'package:flutter/foundation.dart';
import 'package:arc_todo/model/todo_model.dart';
import 'package:intl/intl.dart';

class AddTodoViewState {
  AddTodoViewState({
    required this.title,
    required this.estimatedHours,
    required this.deadline,
  });

  final String title;
  final double estimatedHours;
  final DateTime deadline;

  AddTodoViewState copyWith({
    String? title,
    double? estimatedHours,
    DateTime? deadline,
  }) {
    return AddTodoViewState(
      title: title ?? this.title,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
    );
  }

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);
}

class AddTodoViewModel extends ValueNotifier<AddTodoViewState> {
  AddTodoViewModel(this._model)
      : super(AddTodoViewState(
          title: '',
          estimatedHours: 1.0,
          deadline: DateTime.now().add(const Duration(days: 1)),
        ));

  final TodoModel _model;

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
    if (!isValid) return;

    _model.addTodo(
      title: value.title,
      estimatedHours: value.estimatedHours,
      deadline: value.deadline,
    );
  }

  void reset() {
    value = AddTodoViewState(
      title: '',
      estimatedHours: 1.0,
      deadline: DateTime.now().add(const Duration(days: 1)),
    );
  }

  bool get isValid => value.title.trim().isNotEmpty;
}
