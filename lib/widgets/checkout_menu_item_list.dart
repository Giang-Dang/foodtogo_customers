import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class CheckoutMenuItemList extends StatefulWidget {
  const CheckoutMenuItemList({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<CheckoutMenuItemList> createState() => _CheckoutMenuItemListState();
}

class _CheckoutMenuItemListState extends State<CheckoutMenuItemList> {
  List<MenuItem> _menuItemList = [];
  List<int> _quantity = [];

  Timer? _initTimer;

  initial(int merchantId) async {
    final cartServices = CartServices();

    final List<MenuItem> menuItemList =
        await cartServices.getAllMenuItemsByMerchantId(merchantId);

    List<int> quantity = [];
    if (menuItemList.isNotEmpty) {
      for (var menuItem in menuItemList) {
        var menuItemQuantity = await cartServices.getQuantity(menuItem.id);
        quantity.add(menuItemQuantity);
      }
    }

    if (mounted) {
      setState(() {
        _menuItemList = menuItemList;
        _quantity = quantity;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      initial(widget.merchant.merchantId);
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

    final double deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          _menuItemList.length,
          (index) {
            final imageURL = Uri.http(
                    Secrets.kFoodToGoAPILink, _menuItemList[index].imagePath)
                .toString();
            final String price =
                _menuItemList[index].unitPrice.toStringAsFixed(1);
            final totalPrice =
                (_menuItemList[index].unitPrice * _quantity[index])
                    .toStringAsFixed(1);

            return Container(
              color: KColors.kOnBackgroundColor,
              child: ListTile(
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
                  _menuItemList[index].name,
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
                      '${_quantity[index]}',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
