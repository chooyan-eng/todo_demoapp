import 'package:todo_demoapp/model/member.dart';

class MemberStorage {
  final List<Member> _members = [
    Member(
      id: '1',
      name: 'Current User',
      icon: IconType.person,
    ),
    Member(
      id: '2',
      name: 'Team Member 1',
      icon: IconType.work,
    ),
    Member(
      id: '3',
      name: 'Team Member 2',
      icon: IconType.school,
    ),
  ];

  List<Member> fetchAll() {
    return [..._members];
  }
}
