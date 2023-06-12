class MenuItemDTO {
  const MenuItemDTO({
    required this.id,
    required this.merchantId,
    required this.itemTypeId,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.isClosed,
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

  factory MenuItemDTO.fromJson(Map<String, dynamic> json) {
    return MenuItemDTO(
      id: json['id'],
      merchantId: json['merchantId'],
      itemTypeId: json['itemTypeId'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unitPrice'],
      isClosed: json['isClosed'],
      rating: json['rating'],
    );
  }
}
