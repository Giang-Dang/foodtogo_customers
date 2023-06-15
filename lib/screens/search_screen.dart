import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/search_menu_item_list.dart';
import 'package:foodtogo_customers/widgets/search_merchant_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<Merchant> _merchantList = [];
  List<MenuItem> _menuItemList = [];

  Timer? _initTimer;
  bool _isLoading = true;
  bool _isSearching = false;
  late Color _tabColor;

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
      pageNumber: 1,
      pageSize: 100,
    );

    final merchantServices = MerchantServices();

    final merchantList = await merchantServices.getAll(
      searchName: searchName,
      isDeleted: false,
      pageNumber: 1,
      pageSize: 100,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        _menuItemList = menuItemList ?? [];
        _merchantList = merchantList;
      });
    }
  }

  Color _getTabColor(int tabIndex) {
    if (tabIndex == 0) {
      return KColors.kBlue;
    }
    if (tabIndex == 1) {
      return KColors.kSuccessColor;
    }
    return KColors.kPrimaryColor;
  }

  _setTabColor() {
    if (mounted) {
      setState(() {
        _tabColor = _getTabColor(_tabController.index);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = false;

    _tabColor = _getTabColor(0);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _setTabColor();
    });

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      //
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
      bodyContent = Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        color: KColors.kBackgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 20),
                    hintText: "Search",
                    suffixIcon: IconButton(
                        onPressed: () {
                          _onSearchSubmit(_searchController.text);
                        },
                        icon: _isSearching
                            ? const SizedBox(
                                width: 15.0,
                                height: 15.0,
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : const Icon(
                                Icons.search,
                                color: KColors.kPrimaryColor,
                                size: 20,
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
            ),
            Container(
              height: 30,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
              ),
              child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                    color: _tabColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Merchant'),
                    Tab(text: 'Dishes'),
                  ]),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SearchMerchantList(merchantList: _merchantList),
                  SearchMenuItemList(menuItemList: _menuItemList),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.kBackgroundColor,
        title: const Text(
          'Home',
          style: TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: bodyContent,
    );
  }
}
