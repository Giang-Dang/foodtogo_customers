class MenuItemDTO {
  const MenuItemDTO({
    required this.id,
    required this.merchantId,
    required this.itemTypeId,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.isClosed,
  });
  final int id;
  final int merchantId;
  final int itemTypeId;
  final String name;
  final String description;
  final double unitPrice;
  final bool isClosed;
}
