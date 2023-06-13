import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/favorite_menu_item_services.dart';
import 'package:foodtogo_customers/services/favorite_merchant_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({Key? key}) : super(key: key);

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _initTimer;
  bool _isLoading = true;

  List<MenuItem> _menuItemList = [];
  List<Merchant> _merchantList = [];

  _initial() async {
    final favoriteMenuItemServices = FavoriteMenuItemServices();
    final favoriteMerchantServices = FavoriteMerchantServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final menuItemList =
        await favoriteMenuItemServices.getAllFavoriteMenuItems();
    final merchantList = await favoriteMerchantServices.getAllMerchants();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _menuItemList = menuItemList;
        _merchantList = merchantList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initial();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      color: KColors.kBackgroundColor,
      child: Column(
        children: [
          Container(
            height: 35,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
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
                  color: KColors.kPrimaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: 'Merchants'),
                  Tab(text: 'Dishes'),
                ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Text('Merchants'),
                MenuItemList(menuItemList: _menuItemList),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
