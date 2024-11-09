enum IconType {
  person,
  work,
  school,
  home,
  favorite;

  String get name => toString().split('.').last;
}

class Member {
  Member({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconType icon;
}
