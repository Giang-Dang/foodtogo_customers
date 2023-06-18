class OrderDetailCreateDTO {
  final int id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double unitPrice;
  final String? specialInstruction;

  OrderDetailCreateDTO({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.specialInstruction,
  });

  factory OrderDetailCreateDTO.fromJson(Map<String, dynamic> json) {
    return OrderDetailCreateDTO(
      id: json['id'],
      orderId: json['orderId'],
      menuItemId: json['menuItemId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      specialInstruction: json['specialInstruction'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'menuItemId': menuItemId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'specialInstruction': specialInstruction
      };
}
