import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/providers/favorite_menu_item_list_provider.dart';
import 'package:foodtogo_customers/providers/favorite_merchant_list_provider.dart';
import 'package:foodtogo_customers/services/favorite_menu_item_services.dart';
import 'package:foodtogo_customers/services/favorite_merchant_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';
import 'package:foodtogo_customers/widgets/merchant_list.dart';

class FavoriteWidget extends ConsumerStatefulWidget {
  FavoriteWidget({Key? key, this.addToCart, this.removeFromCart})
      : super(key: key);

  final Function(GlobalKey widgetKey, MenuItem menuItem)? addToCart;
  final Function(MenuItem menuItem)? removeFromCart;

  @override
  ConsumerState<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends ConsumerState<FavoriteWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _initTimer;
  bool _isLoading = true;
  late Color _tabColor;

  List<MenuItem> _menuItemList = [];
  List<Merchant> _merchantList = [];

  _initialize() async {
    final favoriteMenuItemServices = FavoriteMenuItemServices();
    final favoriteMerchantServices = FavoriteMerchantServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final menuItemList =
        await favoriteMenuItemServices.getAllFavoriteMenuItems();
    ref.watch(favoriteMenuItemListProvider.notifier).update(menuItemList);

    final merchantList = await favoriteMerchantServices.getAllMerchants();
    ref.watch(favoriteMerchantListProvider.notifier).update(merchantList);

    if (mounted) {
      setState(() {
        _isLoading = false;
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
    _tabColor = _getTabColor(0);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _setTabColor();
    });
    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
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
    if (!_isLoading) {
      _menuItemList = ref.watch(favoriteMenuItemListProvider);
      _merchantList = ref.watch(favoriteMerchantListProvider);
    }
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
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: _tabColor,
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
                MerchantList(merchantList: _merchantList),
                MenuItemList(
                  menuItemList: _menuItemList,
                  addToCart: widget.addToCart,
                  removeFromCart: widget.removeFromCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
