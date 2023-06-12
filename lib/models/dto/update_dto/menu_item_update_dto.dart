class MenuItemUpdateDTO {
  const MenuItemUpdateDTO({
    required this.id,
    required this.merchantId,
    required this.itemTypeId,
    required this.name,
    required this.description,
    required this.unitPrice,
    this.isClosed = false,
    required this.rating,
  });
  final int id;
  final int merchantId;
  final int itemTypeId;
  final String name;
  final String description;
  final double unitPrice;
  final bool isClosed;
  final double rating;
}
