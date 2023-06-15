import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/settings/kTheme.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/cart_merchant_list.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Merchant> _merchantList = [];

  Timer? _initTimer;

  _initialize() async {
    final cartServices = CartServices();

    final merchantList = await cartServices.getAllMerchants();

    if (mounted) {
      setState(() {
        _merchantList = merchantList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: KColors.kPrimaryColor,
              ),
        ),
      ),
      body: CartMerchantList(merchantList: _merchantList),
    );
  }
}
