import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/dto/create_dto/order_create_dto.dart';
import 'package:foodtogo_customers/models/dto/create_dto/order_details_create_dto.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/order_detail_services.dart';
import 'package:foodtogo_customers/services/order_services.dart';
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

  bool _isPlacingOrder = false;

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

  setPrice({
    required double orderPrice,
    required double shippingFee,
    required double appFee,
    required double promotionDiscount,
  }) {
    _orderPrice = orderPrice;
    _shippingFee = shippingFee;
    _appFee = appFee;
    _promotionDiscount = promotionDiscount;
  }

  calETA({
    required double distance,
  }) {
    final deliveryServices = DeliveryServices();
    final now = DateTime.now();
    final minsETA = deliveryServices.calDeliveryETA(distance).round();
    final hours = minsETA ~/ 60;
    final mins = minsETA % 60;

    _eta = DateTime(
      now.year,
      now.month,
      now.day,
      hours,
      mins,
    );
  }

  _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onPlaceOrderPressed() async {
    if (mounted) {
      setState(() {
        _isPlacingOrder = true;
      });
    }

    final createdOrderId = await _createOrder();
    final menuItemQuantities =
        await _getMenuItemQuantities(widget.merchant.merchantId);
    var isSuccess =
        await _createOrderDetails(createdOrderId, menuItemQuantities);

    isSuccess &= await _removeOrderedItemInCart(menuItemQuantities);

    if (mounted) {
      setState(() {
        _isPlacingOrder = false;
      });
    }

    if (createdOrderId == 0 && !isSuccess) {
      _showAlertDialog('Fail to place your order',
          'We are experiencing problems with placing your order. Please try again later.');
    } else {
      _showAlertDialog('Thank you for choosing us!',
          'Your order has been placed and is being processed.');
    }
  }

  Future<Map<int, int>> _getMenuItemQuantities(int merchantId) async {
    final cartServices = CartServices();

    final menuItemIdList =
        await cartServices.getAllMenuItemIdByMerchantId(merchantId);

    Map<int, int> menuItemQuantities = {};
    for (int id in menuItemIdList) {
      int quantity = await cartServices.getQuantity(id);
      menuItemQuantities[id] = quantity;
    }

    return menuItemQuantities;
  }

  Future<bool> _createOrderDetails(
    int orderId,
    Map<int, int> menuItemQuantities,
  ) async {
    final menuItemServices = MenuItemServices();
    final orderDetailServices = OrderDetailServices();

    bool isSuccess = true;

    List<Future> futures = [];
    menuItemQuantities.forEach((key, value) {
      futures.add(() async {
        var menuItem = await menuItemServices.get(key);

        if (menuItem == null) {
          log('_createOrderDetails menuItem == null');
          isSuccess = false;
        }

        OrderDetailCreateDTO createDTO = OrderDetailCreateDTO(
            id: 0,
            orderId: orderId,
            menuItemId: key,
            quantity: value,
            unitPrice: menuItem!.unitPrice);

        int createdOrderDetailId = await orderDetailServices.create(createDTO);
        if (createdOrderDetailId == 0) {
          log('_createOrderDetails createdOrderDetailId == 0');
          isSuccess = false;
        }
      }());
    });

    await Future.wait(futures);

    return isSuccess;
  }

  Future<int> _createOrder() async {
    final createDTO = OrderCreateDTO(
      id: 0,
      merchantId: widget.merchant.merchantId,
      customerId: UserServices.userId!,
      promotionId: _selectedPromotionId == 0 ? null : _selectedPromotionId,
      placedTime: DateTime.now(),
      eta: _eta,
      deliveryCompletionTime: null,
      orderPrice: _orderPrice,
      shippingFee: _shippingFee,
      appFee: _appFee,
      promotionDiscount: _promotionDiscount,
      status: 'placed',
      deliveryAddress: _deliveryAddress,
      deliveryLongitude: _deliveryLongitude,
      deliveryLatitude: _deliveryLatitude,
    );

    final orderServices = OrderServices();
    final createdOrderId = await orderServices.create(createDTO);

    return createdOrderId;
  }

  Future<bool> _removeOrderedItemInCart(
    Map<int, int> menuItemQuantities,
  ) async {
    final cartServices = CartServices();
    bool isSuccess = true;

    List<Future> futures = [];
    menuItemQuantities.forEach((key, value) {
      futures.add(() async {
        isSuccess = await cartServices.delete(key);
      }());
    });

    await Future.wait(futures);

    return isSuccess;
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
              setPrice: setPrice,
              calETA: calETA,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _onPlaceOrderPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.kPrimaryColor, elevation: 4),
                child: _isPlacingOrder
                    ? const CircularProgressIndicator.adaptive(
                        backgroundColor: KColors.kOnBackgroundColor,
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                            color: KColors.kOnBackgroundColor, fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}
