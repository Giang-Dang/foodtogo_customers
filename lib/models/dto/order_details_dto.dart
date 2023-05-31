class OrderDetailDTO {
  final int id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double unitPrice;
  final String? specialInstruction;

  OrderDetailDTO({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.specialInstruction,
  });

  factory OrderDetailDTO.fromJson(Map<String, dynamic> json) {
    return OrderDetailDTO(
      id: json['id'],
      orderId: json['orderId'],
      menuItemId: json['menuItemId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      specialInstruction: json['specialInstruction'],
    );
  }
}
