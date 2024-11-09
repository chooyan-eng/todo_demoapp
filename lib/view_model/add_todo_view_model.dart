import 'package:flutter/foundation.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/model/member_model.dart';
import 'package:intl/intl.dart';

class AddTodoViewState {
  AddTodoViewState({
    required this.title,
    required this.estimatedHours,
    required this.deadline,
    required this.assignee,
    required this.availableMembers,
    this.errorMessage,
  });

  final String title;
  final double estimatedHours;
  final DateTime deadline;
  final Member assignee;
  final List<Member> availableMembers;
  final String? errorMessage;

  AddTodoViewState copyWith({
    String? title,
    double? estimatedHours,
    DateTime? deadline,
    Member? assignee,
    List<Member>? availableMembers,
    String? errorMessage,
  }) {
    return AddTodoViewState(
      title: title ?? this.title,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
      assignee: assignee ?? this.assignee,
      availableMembers: availableMembers ?? this.availableMembers,
      errorMessage: errorMessage,
    );
  }

  String get formattedDeadline =>
      DateFormat('yyyy/MM/dd HH:mm').format(deadline);
}

class AddTodoViewModel extends ValueNotifier<AddTodoViewState> {
  AddTodoViewModel(this._todoModel, this._memberModel)
      : super(AddTodoViewState(
          title: '',
          estimatedHours: 1.0,
          deadline: DateTime.now().add(const Duration(days: 1)),
          assignee: _memberModel.members.first,
          availableMembers: _memberModel.members,
        ));

  final TodoModel _todoModel;
  final MemberModel _memberModel;

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

  bool save() {
    if (!isValid) return false;

    try {
      _todoModel.addTodo(
        title: value.title,
        estimatedHours: value.estimatedHours,
        deadline: value.deadline,
        assignee: value.assignee,
      );
    } on DeadlineRestrictionException catch (e) {
      value = value.copyWith(errorMessage: e.message);
      return false;
    }
    return true;
  }

  void reset() {
    value = AddTodoViewState(
      title: '',
      estimatedHours: 1.0,
      deadline: DateTime.now().add(const Duration(days: 1)),
      assignee: _memberModel.members.first,
      availableMembers: _memberModel.members,
    );
  }

  bool get isValid => value.title.trim().isNotEmpty;
}
