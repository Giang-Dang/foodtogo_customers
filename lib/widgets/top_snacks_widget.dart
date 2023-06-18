import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/menu_item_type_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_card_list.dart';

class TopSnacksWidget extends StatefulWidget {
  const TopSnacksWidget({Key? key}) : super(key: key);

  @override
  State<TopSnacksWidget> createState() => _TopSnacksWidgetState();
}

class _TopSnacksWidgetState extends State<TopSnacksWidget> {
  List<MenuItem> _menuItemList = [];
  bool _isLoading = true;

  Timer? _initTimer;

  _getMenuItemList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final menuItemServices = MenuItemServices();
    final menuItemTypeServices = MenuItemTypeServices();

    var menuItemTypeDTO = await menuItemTypeServices.getByName('Snacks');

    if (menuItemTypeDTO == null) {
      log('_TopMainCoursesWidgetState._getMenuItemList() menuItemTypeDTO == null');
      return;
    }

    var menuItemList = await menuItemServices.getAll(
      isClosed: false,
      minRating: 4,
      searchItemTypeId: menuItemTypeDTO.id,
      pageNumber: 1,
      pageSize: 10,
    );

    if (menuItemList == null) {
      log('_TopMainCoursesWidgetState._getMenuItemList() menuItemList == null');
      return;
    }

    menuItemList.sort(
      (a, b) {
        return (b.rating * 10 - a.rating * 10).round();
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _menuItemList = menuItemList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _getMenuItemList();
      _initTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget menuItemListContent = const Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
        ],
      ),
    );
    if (!_isLoading) {
      menuItemListContent = Row(
        children: [
          MenuItemCardList(menuItemList: _menuItemList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 5),
          child: Text(
            "Top Snacks",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: KColors.kTextColor),
            textAlign: TextAlign.start,
          ),
        ),
        menuItemListContent,
      ],
    );
  }
}
