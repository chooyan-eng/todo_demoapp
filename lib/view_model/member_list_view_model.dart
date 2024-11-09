import 'package:flutter/foundation.dart';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/model/member_model.dart';

class MemberListViewState {
  MemberListViewState({
    required this.members,
  });

  final List<Member> members;

  MemberListViewState copyWith({
    List<Member>? members,
  }) {
    return MemberListViewState(
      members: members ?? this.members,
    );
  }
}

class MemberListViewModel extends ValueNotifier<MemberListViewState> {
  MemberListViewModel(this._model)
      : super(MemberListViewState(members: _model.members)) {
    _model.memberStream.listen((members) {
      value = value.copyWith(members: members);
    });
  }

  final MemberModel _model;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
