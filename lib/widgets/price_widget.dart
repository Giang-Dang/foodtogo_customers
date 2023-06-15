import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/fee_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/promotion_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class PriceWidget extends StatefulWidget {
  PriceWidget({
    Key? key,
    required this.merchant,
    this.selectedPromotionId,
  }) : super(key: key);

  final Merchant merchant;
  int? selectedPromotionId;

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  double _subTotal = 0;
  double _shippingFee = 0;
  double _appFee = 0;
  double _total = 0;
  double _promotionDiscount = 0;
  double _distance = 0;
  int _totalQuantity = 0;

  Timer? _initTimer;

  Future<double> _calSubTotal(Merchant merchant) async {
    final cartServices = CartServices();
    double subTotal = 0;
    final List<MenuItem> menuItemList =
        await cartServices.getAllMenuItemsByMerchantId(merchant.merchantId);

    if (menuItemList.isNotEmpty) {
      for (var menuItem in menuItemList) {
        var quantity = await cartServices.getQuantity(menuItem.id);

        subTotal += menuItem.unitPrice * quantity;
      }
    }
    return subTotal;
  }

  Future<int> _calTotalQuantity(Merchant merchant) async {
    final cartServices = CartServices();
    final List<MenuItem> menuItemList =
        await cartServices.getAllMenuItemsByMerchantId(merchant.merchantId);

    int totalQuantity = 0;
    if (menuItemList.isNotEmpty) {
      for (var menuItem in menuItemList) {
        var quantity = await cartServices.getQuantity(menuItem.id);

        totalQuantity += quantity;
      }
    }

    return totalQuantity;
  }

  double _calDistance(Merchant merchant) {
    final merchantServices = MerchantServices();
    final distance = merchantServices.calDistance(
      merchant: merchant,
      startLongitude: UserServices.currentLongitude,
      startLatitude: UserServices.currentLatitude,
    );

    return distance;
  }

  Future<double> _calShippingFee(Merchant merchant, double distance) async {
    final feeServices = FeeServices();
    final shippingFee = feeServices.calShippingFee(distance);

    return shippingFee;
  }

  Future<double> _calPromotionDiscount(int promotionId, double subTotal) async {
    final promotionServices = PromotionServices();

    double discount =
        await promotionServices.calPromotionDiscount(promotionId, subTotal);

    return discount;
  }

  _roundDouble(double number, int fractionDigits) {
    return double.parse(number.toStringAsFixed(fractionDigits));
  }

  _initialize(Merchant merchant, int? promotionId) async {
    final feeServices = FeeServices();

    double subTotal = await _calSubTotal(merchant);

    double appFee = feeServices.calAppFee(subTotal);

    double distance = _calDistance(merchant);
    distance = _roundDouble(distance, 1);

    double shippingFee = await _calShippingFee(merchant, distance);

    double promotionDiscount = 0;
    if (promotionId != null) {
      promotionDiscount = await _calPromotionDiscount(promotionId, subTotal);
      promotionDiscount = _roundDouble(promotionDiscount, 1);
    }

    subTotal = _roundDouble(subTotal, 1);
    appFee = _roundDouble(appFee, 1);
    shippingFee = _roundDouble(shippingFee, 1);

    double total = subTotal + appFee + shippingFee - promotionDiscount;
    total = _roundDouble(total, 1);

    final totalQuantity = await _calTotalQuantity(merchant);

    if (mounted) {
      setState(() {
        _subTotal = subTotal;
        _appFee = appFee;
        _shippingFee = shippingFee;
        _promotionDiscount = promotionDiscount;
        _total = total;
        _totalQuantity = totalQuantity;
        _distance = distance;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(microseconds: 100), (timer) {
      // _initialize(widget.merchant, widget.selectedPromotionId);
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
    _initialize(widget.merchant, widget.selectedPromotionId);

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
        children: [
          Container(
            color: KColors.kOnBackgroundColor,
            child: ListTile(
              title: Text('Subtotal ($_totalQuantity item(s) ): '),
              trailing: Text(
                '\$$_subTotal',
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
              title: Text('Shipping Fee ($_distance km): '),
              trailing: Text(
                '\$$_shippingFee',
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
              title: Text('Application Fee: '),
              trailing: Text(
                '\$$_appFee',
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
              title: Text('Promotion: '),
              trailing: Text(
                '- \$$_promotionDiscount',
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
              title: Text('Total: '),
              trailing: Text(
                '\$$_total',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 16,
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
