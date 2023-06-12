import 'package:foodtogo_customers/models/merchant.dart';

class Promotion {
  final int id;
  final Merchant discountCreatorMerchant;
  final String name;
  final String description;
  final int discountPercentage;
  final double discountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final int quantityLeft;

  const Promotion({
    required this.id,
    required this.discountCreatorMerchant,
    required this.name,
    this.description = '',
    required this.discountPercentage,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.quantityLeft,
  });

  // factory Promotion.fromJson(Map<String, dynamic> json) {
  //   return Promotion(
  //     id: json['id'],
  //     discountCreatorMerchant: json['discountCreatorMerchantId'],
  //     name: json['name'],
  //     description: json['description'],
  //     discountPercentage: json['discountPercentage'],
  //     discountAmount: json['discountAmount'].toDouble(),
  //     startDate: DateTime.parse(json['startDate']),
  //     endDate: DateTime.parse(json['endDate']),
  //     quantity: json['quantity'],
  //     quantityLeft: json['quantityLeft'],
  //   );
  // }
}
