import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/merchant_list_item.dart';

class MerchantList extends StatefulWidget {
  const MerchantList({
    Key? key,
    required this.merchantList,
  }) : super(key: key);

  final List<Merchant> merchantList;

  @override
  State<MerchantList> createState() => _MerchantListState();
}

class _MerchantListState extends State<MerchantList> {
  @override
  Widget build(BuildContext context) {
    final merchantList = widget.merchantList;

    return Container(
      color: KColors.kBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        itemCount: merchantList.length,
        itemBuilder: (context, index) => MerchantListItem(
          merchant: merchantList[index],
        ),
      ),
    );
  }
}
