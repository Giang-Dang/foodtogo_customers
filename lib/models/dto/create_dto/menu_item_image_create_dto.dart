class MenuItemImageCreateDTO {
  const MenuItemImageCreateDTO({
    this.id = 0,
    required this.menuItemId,
    required this.path,
  });
  final int id;
  final int menuItemId;
  final String path;
}
