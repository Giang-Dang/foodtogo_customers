class OrderDTO {
  final int id;
  final int merchantId;
  final int? shipperId;
  final int customerId;
  final int? promotionId;
  final DateTime placedTime;
  final DateTime eta;
  final DateTime? deliveryCompletionTime;
  final double orderPrice;
  final double shippingFee;
  final double appFee;
  final double promotionDiscount;
  final String status;
  final String? cancelledBy;
  final String? cancellationReason;
  final String deliveryAddress;
  final double deliveryLongitude;
  final double deliveryLatitude;

  const OrderDTO({
    required this.id,
    required this.merchantId,
    this.shipperId,
    required this.customerId,
    this.promotionId,
    required this.placedTime,
    required this.eta,
    required this.deliveryCompletionTime,
    required this.orderPrice,
    required this.shippingFee,
    required this.appFee,
    required this.promotionDiscount,
    required this.status,
    this.cancelledBy = '',
    this.cancellationReason = '',
    required this.deliveryAddress,
    required this.deliveryLongitude,
    required this.deliveryLatitude,
  });

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    return OrderDTO(
      id: json['id'],
      merchantId: json['merchantId'],
      shipperId: json['shipperId'],
      customerId: json['customerId'],
      promotionId: json['promotionId'],
      placedTime: DateTime.parse(json['placedTime']),
      eta: DateTime.parse(json['eta']),
      deliveryCompletionTime: json['deliveryCompletionTime'] != null
          ? DateTime.parse(json['deliveryCompletionTime'])
          : null,
      orderPrice: json['orderPrice'],
      shippingFee: json['shippingFee'],
      appFee: json['appFee'],
      promotionDiscount: json['promotionDiscount'],
      status: json['status'],
      cancelledBy: json['cancelledBy'],
      cancellationReason: json['cancellationReason'],
      deliveryAddress: json['deliveryAddress'],
      deliveryLongitude: json['deliveryLongitude'],
      deliveryLatitude: json['deliveryLatitude'],
    );
  }
}
