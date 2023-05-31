class MenuItemImageUpdateDTO {
  const MenuItemImageUpdateDTO({
    required this.id,
    required this.menuItemId,
    required this.path,
  });
  final int id;
  final int menuItemId;
  final String path;
}
