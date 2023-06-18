import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/order_detail.dart';
import 'package:foodtogo_customers/services/order_detail_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderMenuItemList extends StatefulWidget {
  const OrderMenuItemList({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  final int orderId;

  @override
  State<OrderMenuItemList> createState() => _OrderMenuItemListState();
}

class _OrderMenuItemListState extends State<OrderMenuItemList> {
  List<OrderDetail> _orderDetailsList = [];

  Timer? _initTimer;

  initial(int orderId) async {
    final orderDetailServices = OrderDetailServices();

    final orderDetailsList = await orderDetailServices.getAll(
          searchOrderId: orderId,
        ) ??
        [];

    if (mounted) {
      setState(() {
        _orderDetailsList = orderDetailsList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      initial(widget.orderId);
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jwtToken = UserServices.jwtToken;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: KColors.kLightTextColor,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: KColors.kOnBackgroundColor,
          ),
          child: Column(
            children: List.generate(
              _orderDetailsList.length,
              (index) {
                final imageURL = Uri.http(Secrets.kFoodToGoAPILink,
                        _orderDetailsList[index].menuItem.imagePath)
                    .toString();
                final String price = _orderDetailsList[index]
                    .menuItem
                    .unitPrice
                    .toStringAsFixed(1);
                final totalPrice =
                    (_orderDetailsList[index].menuItem.unitPrice *
                            _orderDetailsList[index].quantity)
                        .toStringAsFixed(1);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(
                        imageURL,
                        headers: {
                          'Authorization': 'Bearer $jwtToken',
                        },
                      ),
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    _orderDetailsList[index].menuItem.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: KColors.kTextColor,
                        ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        '\$$price',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: KColors.kTextColor,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'x',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: KColors.kTextColor,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_orderDetailsList[index].quantity}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: KColors.kTextColor,
                            ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    totalPrice.toString(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: KColors.kTextColor,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
