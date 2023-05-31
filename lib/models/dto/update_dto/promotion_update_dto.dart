class PromotionUpdateDTO {
  final int id;
  final int discountCreatorMerchantId;
  final String name;
  final String description;
  final int discountPercentage;
  final double discountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final int quantityLeft;

  const PromotionUpdateDTO({
    required this.id,
    required this.discountCreatorMerchantId,
    required this.name,
    this.description = '',
    required this.discountPercentage,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.quantityLeft,
  });

  factory PromotionUpdateDTO.fromJson(Map<String, dynamic> json) {
    return PromotionUpdateDTO(
      id: json['id'],
      discountCreatorMerchantId: json['discountCreatorMerchantId'],
      name: json['name'],
      description: json['description'],
      discountPercentage: json['discountPercentage'],
      discountAmount: json['discountAmount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      quantity: json['quantity'],
      quantityLeft: json['quantityLeft'],
    );
  }
}
