import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_card_list_item.dart';

class MenuItemCardList extends StatefulWidget {
  const MenuItemCardList({
    Key? key,
    required this.menuItemList,
  }) : super(key: key);

  final List<MenuItem> menuItemList;

  @override
  State<MenuItemCardList> createState() => _MenuItemCardListState();
}

class _MenuItemCardListState extends State<MenuItemCardList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    const double containerHeight = 260;

    final menuItemList = widget.menuItemList;

    return Container(
      height: containerHeight,
      width: deviceWidth,
      color: KColors.kBackgroundColor,
      child: SizedBox(
        width: deviceWidth,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: menuItemList.length + 2,
          itemBuilder: (context, index) {
            if (index == 0 || index == menuItemList.length + 1) {
              return const SizedBox(width: 15);
            } else {
              return MenuItemCardListItem(
                key: ValueKey(menuItemList[index - 1].id),
                menuItem: menuItemList[index - 1],
                maxHeight: containerHeight,
              );
            }
          },
        ),
      ),
    );
  }
}
