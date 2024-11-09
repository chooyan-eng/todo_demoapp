import 'package:flutter/material.dart';
import 'package:todo_demoapp/model/member.dart';

class MemberSelectField extends StatelessWidget {
  const MemberSelectField({
    super.key,
    required this.members,
    required this.selectedMember,
    required this.onChanged,
    this.label = 'Assignee',
  });

  final List<Member> members;
  final Member selectedMember;
  final ValueChanged<Member> onChanged;
  final String label;

  IconData _getIconData(IconType iconType) {
    switch (iconType) {
      case IconType.person:
        return Icons.person;
      case IconType.work:
        return Icons.work;
      case IconType.school:
        return Icons.school;
      case IconType.home:
        return Icons.home;
      case IconType.favorite:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMember.id,
          isDense: true,
          isExpanded: true,
          items: members.map((member) {
            return DropdownMenuItem(
              value: member.id,
              child: Row(
                children: [
                  Icon(
                    _getIconData(member.icon),
                    size: 20,
                    color: Colors.tealAccent[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? memberId) {
            if (memberId == null) return;
            final member = members.firstWhere((m) => m.id == memberId);
            onChanged(member);
          },
        ),
      ),
    );
  }
}
