import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list_item.dart';

class MerchantMenuItemList extends StatefulWidget {
  const MerchantMenuItemList({
    Key? key,
    required this.menuItemList,
    this.addToCart,
    this.removeFromCart,
  }) : super(key: key);

  final List<MenuItem> menuItemList;
  final Function(GlobalKey widgetKey, MenuItem menuItem)? addToCart;
  final Function(MenuItem menuItem)? removeFromCart;

  @override
  State<MerchantMenuItemList> createState() => _MerchantMenuItemListState();
}

class _MerchantMenuItemListState extends State<MerchantMenuItemList> {
  @override
  Widget build(BuildContext context) {
    final menuItemList = widget.menuItemList;

    return Container(
        color: KColors.kBackgroundColor,
        child: Column(
          children: [
            for (var menuItem in menuItemList)
              MenuItemListItem(
                menuItem: menuItem,
                addToCart: widget.addToCart,
                removeFromCart: widget.removeFromCart,
              ),
          ],
        ));
  }
}
