class MenuItemCreateDTO {
  const MenuItemCreateDTO({
    required this.id,
    required this.merchantId,
    required this.itemTypeId,
    required this.name,
    required this.description,
    required this.unitPrice,
    this.isClosed = false,
  });
  final int id;
  final int merchantId;
  final int itemTypeId;
  final String name;
  final String description;
  final double unitPrice;
  final bool isClosed;
}
