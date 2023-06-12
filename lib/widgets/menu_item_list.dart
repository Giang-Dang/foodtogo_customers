import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list_item.dart';

class MenuItemList extends StatefulWidget {
  const MenuItemList({
    Key? key,
    required this.menuItemList,
  }) : super(key: key);

  final List<MenuItem> menuItemList;

  @override
  State<MenuItemList> createState() => _MenuItemListState();
}

class _MenuItemListState extends State<MenuItemList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    const double containerHeight = 240;

    final menuItemList = widget.menuItemList;

    return Container(
      height: containerHeight,
      width: deviceWidth,
      color: KColors.kBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: deviceWidth,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 15),
              for (var menuItem in menuItemList)
                MenuItemListItem(
                  menuItem: menuItem,
                  maxHeight: containerHeight,
                ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
