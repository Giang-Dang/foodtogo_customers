import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class OrderDeliverAddress extends StatelessWidget {
  const OrderDeliverAddress({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deliver Address',
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
                title: Text(
                  '${order.customer.lastName} ${order.customer.middleName} ${order.customer.firstName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(order.customer.phoneNumber),
              ),
              ListTile(
                leading: const Icon(Icons.pin_drop_outlined),
                title: Text(
                  order.deliveryAddress,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
