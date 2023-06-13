import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/menu_item_type.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/menu_item_type_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';
import 'package:foodtogo_customers/widgets/menu_item_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<MenuItemType> _menuItemTypeList = [];
  List<MenuItem> _menuItemList = [];

  Timer? _initTimer;
  bool _isLoading = true;
  bool _isSearching = false;

  _initial() async {
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

  _onSearchSubmit(String searchName) async {
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    final menuItemServices = MenuItemServices();

    final menuItemList = await menuItemServices.getAll(
      searchName: searchName,
      isClosed: false,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        _menuItemList = menuItemList ?? [];
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
      _initial();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    _searchController.dispose();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = const Center(
      child: CircularProgressIndicator(),
    );

    if (!_isLoading) {
      bodyContent = Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                hintText: "Search",
                suffixIcon: IconButton(
                    onPressed: () {
                      _onSearchSubmit(_searchController.text);
                    },
                    icon: _isSearching
                        ? const SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: Center(child: CircularProgressIndicator()))
                        : const Icon(
                            Icons.search,
                            color: KColors.kPrimaryColor,
                          )),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: KColors.kPrimaryColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: KColors.kPrimaryColor,
                  ),
                ),
              ),
              onSubmitted: (value) {
                _onSearchSubmit(value);
              },
            ),
          ),
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                  color: KColors.kPrimaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  const Tab(text: '     All     '),
                  for (var type in _menuItemTypeList)
                    Tab(text: '  ${type.name}  '),
                ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MenuItemList(menuItemList: _menuItemList),
                for (var type in _menuItemTypeList)
                  MenuItemList(menuItemList: _filter(_menuItemList, type)),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: bodyContent,
    );
  }
}
