class MenuItemType {
  const MenuItemType({
    required this.id,
    required this.name,
  });
  final int id;
  final String name;

  factory MenuItemType.fromJson(Map<String, dynamic> json) {
    return MenuItemType(
      id: json['id'],
      name: json['name'],
    );
  }
}
