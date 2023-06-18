import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class OrderPriceWidget extends StatelessWidget {
  const OrderPriceWidget({Key? key, required this.order}) : super(key: key);

  final Order order;

  double _calDistance(
      {required Merchant merchant,
      required double startLongitude,
      required double startLatitude}) {
    final merchantServices = MerchantServices();
    final distance = merchantServices.calDistance(
      merchant: merchant,
      startLongitude: UserServices.currentLongitude,
      startLatitude: UserServices.currentLatitude,
    );

    return distance;
  }

  _roundDouble(double number, int fractionDigits) {
    return double.parse(number.toStringAsFixed(fractionDigits));
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calDistance(
      merchant: order.merchant,
      startLongitude: order.deliveryLongitude,
      startLatitude: order.deliveryLatitude,
    );

    final total = order.appFee +
        order.shippingFee +
        order.orderPrice -
        order.promotionDiscount;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: KColors.kOnBackgroundColor,
      ),
      child: Column(
        children: [
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: Text('Subtotal: '),
              trailing: Text(
                '\$${order.orderPrice.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kTextColor,
                      fontSize: 14,
                    ),
              ),
            ),
          ),
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: Text('Shipping Fee (${distance.toStringAsFixed(1)} km): '),
              trailing: Text(
                '\$${order.shippingFee.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kTextColor,
                      fontSize: 14,
                    ),
              ),
            ),
          ),
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: const Text('Application Fee: '),
              trailing: Text(
                '\$${order.appFee.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kTextColor,
                      fontSize: 14,
                    ),
              ),
            ),
          ),
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: const Text('Promotion: '),
              trailing: Text(
                '- \$${order.promotionDiscount.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kSuccessColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: const Text('Total: '),
              trailing: Text(
                '\$${total.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
