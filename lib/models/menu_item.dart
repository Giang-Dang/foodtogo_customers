class MenuItem {
  const MenuItem({
    required this.id,
    required this.merchantId,
    required this.itemType,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.isClosed,
    required this.imagePath,
    required this.rating,
  });
  final int id;
  final int merchantId;
  final String itemType;
  final String name;
  final String description;
  final double unitPrice;
  final bool isClosed;
  final String imagePath;
  final double rating;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      merchantId: json['merchantId'],
      itemType: json['itemType'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unitPrice'],
      isClosed: json['isClosed'],
      imagePath: json['imagePath'],
      rating: json['rating'],
    );
  }
}
