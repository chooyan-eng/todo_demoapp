import 'dart:async';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/storage/member_storage.dart';

class MemberModel {
  MemberModel(this._storage) {
    _members.addAll(_storage.fetchAll());
    _memberController.add(_members);
  }

  final MemberStorage _storage;
  final _memberController = StreamController<List<Member>>.broadcast();
  final List<Member> _members = [];

  Stream<List<Member>> get memberStream => _memberController.stream;
  List<Member> get members => List.unmodifiable(_members);

  void dispose() {
    _memberController.close();
  }
}
