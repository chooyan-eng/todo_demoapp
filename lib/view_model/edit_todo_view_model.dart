import 'package:flutter/foundation.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:intl/intl.dart';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/model/member_model.dart';

class EditTodoViewState {
  EditTodoViewState({
    required this.title,
    required this.estimatedHours,
    required this.deadline,
    required this.assignee,
    required this.availableMembers,
  });

  final String title;
  final double estimatedHours;
  final DateTime deadline;
  final Member assignee;
  final List<Member> availableMembers;

  EditTodoViewState copyWith({
    String? title,
    double? estimatedHours,
    DateTime? deadline,
    Member? assignee,
    List<Member>? availableMembers,
  }) {
    return EditTodoViewState(
      title: title ?? this.title,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
      assignee: assignee ?? this.assignee,
      availableMembers: availableMembers ?? this.availableMembers,
    );
  }

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);
}

class EditTodoViewModel extends ValueNotifier<EditTodoViewState> {
  EditTodoViewModel(this._todoModel, MemberModel memberModel, Todo todo)
      : _todoId = todo.id,
        super(EditTodoViewState(
          title: todo.title,
          estimatedHours: todo.estimatedHours,
          deadline: todo.deadline,
          assignee: todo.assignee,
          availableMembers: memberModel.members,
        ));

  final TodoModel _todoModel;
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

  void updateAssignee(Member member) {
    value = value.copyWith(assignee: member);
  }

  void save() {
    if (value.title.trim().isEmpty) return;

    _todoModel.updateTodo(
      _todoId,
      title: value.title,
      estimatedHours: value.estimatedHours,
      deadline: value.deadline,
      assignee: value.assignee,
    );
  }

  bool get isValid => value.title.trim().isNotEmpty;
}
