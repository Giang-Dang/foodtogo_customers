class OrderCreateDTO {
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

  const OrderCreateDTO({
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

  factory OrderCreateDTO.fromJson(Map<String, dynamic> json) {
    return OrderCreateDTO(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantId': merchantId,
        'shipperId': shipperId,
        'customerId': customerId,
        'promotionId': promotionId,
        'placedTime': placedTime.toIso8601String(),
        'eta': eta.toIso8601String(),
        'deliveryCompletionTime': deliveryCompletionTime?.toIso8601String(),
        'orderPrice': orderPrice,
        'shippingFee': shippingFee,
        'appFee': appFee,
        'promotionDiscount': promotionDiscount,
        'status': status,
        'cancelledBy': cancelledBy,
        'cancellationReason': cancellationReason,
        'deliveryAddress': deliveryAddress,
        'deliveryLongitude': deliveryLongitude,
        'deliveryLatitude': deliveryLatitude
      };
}
