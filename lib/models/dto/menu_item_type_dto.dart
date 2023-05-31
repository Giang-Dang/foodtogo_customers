class MenuItemTypeDTO {
  const MenuItemTypeDTO({
    required this.id,
    required this.name,
  });
  final int id;
  final String name;
  factory MenuItemTypeDTO.fromJson(Map<String, dynamic> json) {
    return MenuItemTypeDTO(
      id: json['id'],
      name: json['name'],
    );
  }
}
