class DuaFolder {
  final String id;
  String name;
  String icon;
  int count;

  DuaFolder({
    required this.id,
    required this.name,
    required this.icon,
    this.count = 0,
  });

  DuaFolder copyWith({String? name, String? icon, int? count}) {
    return DuaFolder(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      count: count ?? this.count,
    );
  }
}
