import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/checkout_delivery_address.dart';
import 'package:foodtogo_customers/widgets/checkout_menu_item_list.dart';
import 'package:foodtogo_customers/widgets/checkout_promotion_list.dart';
import 'package:foodtogo_customers/widgets/checkout_price_widget.dart';

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
  int _selectedPromotionId = 0;
  DateTime _eta = DateTime.now();
  double _orderPrice = 0; //subTotal
  double _shippingFee = 0;
  double _appFee = 0;
  double _promotionDiscount = 0;
  String _deliveryAddress = '';
  double _deliveryLongitude = UserServices.currentLongitude;
  double _deliveryLatitude = UserServices.currentLatitude;

  setSelectedPromotionId(int value) {
    setState(() {
      _selectedPromotionId = value;
    });
  }

  setDeliveryLocation({
    required double newDeliveryLongitude,
    required double newDeliveryLatitude,
    required String newDeliveryAddress,
  }) {
    _deliveryAddress = newDeliveryAddress;
    _deliveryLatitude = newDeliveryLatitude;
    _deliveryLongitude = newDeliveryLongitude;
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
            const SizedBox(height: 10),
            CheckoutDeliveryAddress(
              deliveryLatitude: _deliveryLatitude,
              deliveryLongitude: _deliveryLongitude,
              setDeliveryLocation: setDeliveryLocation,
            ),
            const SizedBox(height: 10),
            CheckoutMenuItemList(merchant: merchant),
            const SizedBox(height: 10),
            CheckoutPromotionList(
              merchant: merchant,
              getSelectedPromotionId: setSelectedPromotionId,
            ),
            const SizedBox(height: 10),
            CheckoutPriceWidget(
              merchant: merchant,
              selectedPromotionId: _selectedPromotionId,
              deliveryLatitude: _deliveryLatitude,
              deliveryLongitude: _deliveryLongitude,
            ),
          ]),
        ),
      ),
    );
  }
}
