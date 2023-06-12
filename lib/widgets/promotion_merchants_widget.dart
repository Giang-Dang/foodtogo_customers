import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/services/promotion_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/merchant_list.dart';
import 'package:foodtogo_customers/widgets/promotion_list.dart';

class PromotionMerchantsWidget extends StatefulWidget {
  const PromotionMerchantsWidget({Key? key}) : super(key: key);

  @override
  State<PromotionMerchantsWidget> createState() =>
      _PromotionMerchantsWidgetState();
}

class _PromotionMerchantsWidgetState extends State<PromotionMerchantsWidget> {
  List<Promotion> _promotionList = [];
  bool _isLoading = true;

  Timer? _initTimer;

  _getPromotionMerchantList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final promotionServices = PromotionServices();

    final promotionList =
        await promotionServices.getAll(checkingDate: DateTime.now());

    if (mounted) {
      setState(() {
        _isLoading = false;
        _promotionList = promotionList ?? [];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _getPromotionMerchantList();
      _initTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget merchantListcontain = const Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
        ],
      ),
    );
    if (!_isLoading) {
      merchantListcontain = Row(
        children: [
          PromotionList(promotionList: _promotionList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 5),
          child: Text(
            "Promotions",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: KColors.kTextColor, fontSize: 24),
            textAlign: TextAlign.start,
          ),
        ),
        merchantListcontain,
      ],
    );
  }
}
