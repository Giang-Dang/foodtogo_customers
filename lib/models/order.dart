import 'package:foodtogo_customers/models/customer.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/models/shipper.dart';

class Order {
  final int id;
  final Merchant merchant;
  final Shipper? shipper;
  final Customer customer;
  final Promotion? promotion;
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

  const Order({
    required this.id,
    required this.merchant,
    required this.shipper,
    required this.customer,
    required this.promotion,
    required this.placedTime,
    required this.eta,
    required this.deliveryCompletionTime,
    required this.orderPrice,
    required this.shippingFee,
    required this.appFee,
    required this.promotionDiscount,
    required this.status,
    this.cancelledBy,
    this.cancellationReason,
    required this.deliveryAddress,
    required this.deliveryLongitude,
    required this.deliveryLatitude,
  });
}
