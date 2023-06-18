import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/enum/user_type.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/screens/rating_user_screen.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/rating_button.dart';

class OrderShipper extends StatelessWidget {
  const OrderShipper({
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
          builder: (context) => RatingUserScreen(
              order: order, fromUserType: fromUserType, toUserType: toUserType),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return order.shipper == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shipper',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kLightTextColor,
                      fontSize: 22,
                    ),
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
                      leading: const Icon(Icons.person),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.shipper!.lastName} ${order.shipper!.middleName} ${order.shipper!.firstName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RatingBarIndicator(
                            rating: order.shipper!.rating,
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
                                toUserType: UserType.Shipper,
                                order: order);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.two_wheeler),
                      title: Text(
                        order.shipper!.vehicleNumberPlate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(order.shipper!.vehicleType),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(order.shipper!.phoneNumber),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(order.shipper!.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: Text(
                          '${order.shipper!.successOrderCount} order(s) / ${order.shipper!.cancelledOrderCount + order.shipper!.successOrderCount} order(s)'),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
