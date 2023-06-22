import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/menu_item_type.dart';
import 'package:foodtogo_customers/services/menu_item_type_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';

class SearchMenuItemList extends StatefulWidget {
  const SearchMenuItemList({
    Key? key,
    required this.menuItemList,
  }) : super(key: key);

  final List<MenuItem> menuItemList;

  @override
  State<SearchMenuItemList> createState() => _SearchMenuItemListState();
}

class _SearchMenuItemListState extends State<SearchMenuItemList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<MenuItemType> _menuItemTypeList = [];

  Timer? _initTimer;
  bool _isLoading = true;

  _initialize() async {
    final menuItemTypeServices = MenuItemTypeServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final List<MenuItemType> menuItemTypeList =
        await menuItemTypeServices.getAll();

    _tabController =
        TabController(length: menuItemTypeList.length + 1, vsync: this);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _menuItemTypeList = menuItemTypeList;
      });
    }
  }

  List<MenuItem> _filter(List<MenuItem> menuItemList, MenuItemType type) {
    return menuItemList
        .where((e) => e.itemType.toLowerCase() == type.name.toLowerCase())
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItemList = widget.menuItemList;

    Widget content = const Center(
      child: CircularProgressIndicator(),
    );

    if (!_isLoading) {
      content = Column(
        children: [
          Container(
            height: 30,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: KColors.kPrimaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  const Tab(text: '     All     '),
                  for (var type in _menuItemTypeList)
                    Tab(text: '     ${type.name}     '),
                ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MenuItemList(menuItemList: menuItemList),
                for (var type in _menuItemTypeList)
                  MenuItemList(menuItemList: _filter(menuItemList, type)),
              ],
            ),
          ),
        ],
      );
    }

    return content;
  }
}
