import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/enum/user_type.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/screens/merchant_info_screen.dart';
import 'package:foodtogo_customers/screens/rating_merchant_screen.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/rating_button.dart';

class OrderMerchant extends StatelessWidget {
  const OrderMerchant({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  _navigateToRatingScreen(
      {required BuildContext context,
      required UserType fromUserType,
      required UserType toUserType,
      required Order order}) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RatingMerchantScreen(order: order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Merchant',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            IconButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MerchantInfoScreen(merchant: order.merchant),
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.info_outlined,
                color: KColors.kPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: KColors.kOnBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.store_outlined),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.merchant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RatingBarIndicator(
                      rating: order.merchant.rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                trailing: Transform.translate(
                  offset: const Offset(10, 2),
                  child: RatingButton(
                    onButtonPressed: () {
                      _navigateToRatingScreen(
                          context: context,
                          fromUserType: UserType.Customer,
                          toUserType: UserType.Merchant,
                          order: order);
                    },
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(
                  order.merchant.phoneNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pin_drop_outlined),
                title: Text(order.merchant.address),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
