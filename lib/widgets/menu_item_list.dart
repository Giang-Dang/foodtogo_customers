import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list_item.dart';

class MenuItemList extends StatefulWidget {
  const MenuItemList({
    Key? key,
    required this.menuItemList,
    this.addToCart,
    this.removeFromCart,
    this.onTap,
  }) : super(key: key);

  final List<MenuItem> menuItemList;
  final Function(GlobalKey widgetKey, MenuItem menuItem)? addToCart;
  final Function(MenuItem menuItem)? removeFromCart;
  final Function(MenuItem menuItem)? onTap;

  @override
  State<MenuItemList> createState() => _MenuItemListState();
}

class _MenuItemListState extends State<MenuItemList> {
  @override
  Widget build(BuildContext context) {
    final menuItemList = widget.menuItemList;

    return Container(
      color: KColors.kBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        itemCount: menuItemList.length,
        itemBuilder: (context, index) => MenuItemListItem(
          menuItem: menuItemList[index],
          addToCart: widget.addToCart,
          removeFromCart: widget.removeFromCart,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
