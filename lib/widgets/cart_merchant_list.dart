import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/cart_merchant_list_item.dart';

class CartMerchantList extends StatefulWidget {
  const CartMerchantList({
    Key? key,
    required this.merchantList,
  }) : super(key: key);

  final List<Merchant> merchantList;

  @override
  State<CartMerchantList> createState() => _CartMerchantListState();
}

class _CartMerchantListState extends State<CartMerchantList> {
  @override
  Widget build(BuildContext context) {
    final merchantList = widget.merchantList;

    return Container(
      color: KColors.kBackgroundColor,
      child: ListView.builder(
        itemCount: merchantList.length,
        itemBuilder: (context, index) => CartMerchantListItem(
          merchant: merchantList[index],
        ),
      ),
    );
  }
}
