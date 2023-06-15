import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/promotion_list_item.dart';

class PromotionList extends StatefulWidget {
  const PromotionList({
    Key? key,
    required this.promotionList,
  }) : super(key: key);

  final List<Promotion> promotionList;

  @override
  State<PromotionList> createState() => _PromotionListState();
}

class _PromotionListState extends State<PromotionList> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    const double containerHeight = 215;

    final promotionList = widget.promotionList;

    return Container(
      height: containerHeight,
      width: deviceWidth,
      color: KColors.kBackgroundColor,
      child: SizedBox(
        width: deviceWidth,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: promotionList.length + 2,
          itemBuilder: (context, index) {
            if (index == 0 || index == promotionList.length + 1) {
              return const SizedBox(width: 15);
            } else {
              return PromotionListItem(
                promotion: promotionList[index - 1],
                maxHeight: containerHeight,
              );
            }
          },
        ),
      ),
    );
  }
}
