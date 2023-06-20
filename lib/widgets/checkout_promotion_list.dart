import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/services/promotion_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class CheckoutPromotionList extends StatefulWidget {
  const CheckoutPromotionList({
    Key? key,
    required this.merchant,
    required this.getSelectedPromotionId,
  }) : super(key: key);

  final Merchant merchant;
  final Function(int promotionId) getSelectedPromotionId;

  @override
  State<CheckoutPromotionList> createState() => _CheckoutPromotionListState();
}

class _CheckoutPromotionListState extends State<CheckoutPromotionList> {
  List<Promotion> _promotionList = [];
  int? _selectedPromotionId;

  Timer? _initTimer;

  _updatePromotionList(Merchant merchant) async {
    final promotionServices = PromotionServices();

    var promotionList = await promotionServices.getAll(
          searchMerchantId: merchant.merchantId,
          checkingDate: DateTime.now(),
        ) ??
        [];

    if (promotionList.isEmpty) {
      return;
    }

    promotionList = promotionList.where((p) => p.quantityLeft > 0).toList();

    if (mounted) {
      setState(() {
        _promotionList = promotionList;
      });
    }
  }

  _initialize(Merchant merchant) async {
    _updatePromotionList(merchant);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize(widget.merchant);
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
    return _promotionList.isEmpty
        ? const Divider()
        : Container(
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
            child: Column(children: [
              Container(
                color: KColors.kOnBackgroundColor,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                child: Text(
                  'Promotions:',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: KColors.kTextColor,
                        fontSize: 18,
                      ),
                ),
              ),
              for (var promotion in _promotionList)
                Container(
                  color: KColors.kOnBackgroundColor,
                  child: RadioListTile(
                    title: Text(
                      promotion.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: KColors.kTextColor,
                            fontSize: 16,
                          ),
                    ),
                    value: promotion.id,
                    groupValue: _selectedPromotionId,
                    onChanged: (value) {
                      if (value != null) {
                        widget.getSelectedPromotionId(value);
                      }
                      if (mounted) {
                        setState(() {
                          _selectedPromotionId = value;
                        });
                      }
                    },
                  ),
                )
            ]),
          );
  }
}
