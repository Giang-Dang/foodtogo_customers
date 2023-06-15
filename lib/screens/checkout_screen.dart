import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/checkout_menu_item_list.dart';
import 'package:foodtogo_customers/widgets/checkout_promotion_list.dart';
import 'package:foodtogo_customers/widgets/price_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int? _selectedPromotionId;

  setSelectedPromotionId(int value) {
    if (mounted) {
      setState(() {
        _selectedPromotionId = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final merchant = widget.merchant;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        height: deviceHeight,
        color: KColors.kBackgroundColor,
        child: SingleChildScrollView(
          child: Column(children: [
            CheckoutMenuItemList(merchant: merchant),
            const SizedBox(height: 10),
            CheckoutPromotionList(
              merchant: merchant,
              getSelectedPromotionId: setSelectedPromotionId,
            ),
            const SizedBox(height: 10),
            PriceWidget(
              merchant: merchant,
              selectedPromotionId: _selectedPromotionId,
            ),
          ]),
        ),
      ),
    );
  }
}
