import 'package:foodtogo_customers/models/menu_item.dart';

class OrderDetail {
  final int id;
  final int orderId;
  final MenuItem menuItem;
  final int quantity;
  final double unitPrice;
  final String? specialInstruction;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.menuItem,
    required this.quantity,
    required this.unitPrice,
    this.specialInstruction,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['orderId'],
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      specialInstruction: json['specialInstruction'],
    );
  }
}
