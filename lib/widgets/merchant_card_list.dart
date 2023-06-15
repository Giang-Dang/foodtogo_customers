import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/merchant_card_list_item.dart';

class MerchantCardList extends StatefulWidget {
  const MerchantCardList({
    Key? key,
    required this.merchantList,
  }) : super(key: key);

  final List<Merchant> merchantList;

  @override
  State<MerchantCardList> createState() => _MerchantCardListState();
}

class _MerchantCardListState extends State<MerchantCardList> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    const double containerHeight = 220;

    final merchantList = widget.merchantList;

    return Container(
      height: containerHeight,
      width: deviceWidth,
      color: KColors.kBackgroundColor,
      child: SizedBox(
        width: deviceWidth,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: merchantList.length + 2,
          itemBuilder: (context, index) {
            if (index == 0 || index == merchantList.length + 1) {
              return const SizedBox(width: 15);
            } else {
              return MerchantCardListItem(
                key: ValueKey(merchantList[index - 1].merchantId),
                merchant: merchantList[index - 1],
                maxHeight: containerHeight,
              );
            }
          },
        ),
      ),
    );
  }
}
