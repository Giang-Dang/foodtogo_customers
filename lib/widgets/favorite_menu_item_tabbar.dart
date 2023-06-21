import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/screens/merchant_screen.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';

class FavoriteMenuItemTabbar extends StatefulWidget {
  const FavoriteMenuItemTabbar({
    Key? key,
    required this.menuItemList,
    this.addToCart,
    this.removeFromCart,
  }) : super(key: key);

  final Function(GlobalKey widgetKey, MenuItem menuItem)? addToCart;
  final Function(MenuItem menuItem)? removeFromCart;
  final List<MenuItem> menuItemList;

  @override
  State<FavoriteMenuItemTabbar> createState() => _FavoriteMenuItemTabbarState();
}

class _FavoriteMenuItemTabbarState extends State<FavoriteMenuItemTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _tabColor;

  Color _getTabColor(int tabIndex) {
    if (tabIndex == 0) {
      return KColors.kDanger;
    }
    if (tabIndex == 1) {
      return KColors.kBrightLavender;
    }
    return KColors.kWebOrange;
  }

  _setTabColor() {
    if (mounted) {
      setState(() {
        _tabColor = _getTabColor(_tabController.index);
      });
    }
  }

  onMenuItemTap(MenuItem menuItem) async {
    final merchantServices = MerchantServices();
    final merchant = await merchantServices.get(menuItem.merchantId);
    if (merchant == null) {
      return;
    }
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MerchantScreen(merchant: merchant),
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabColor = _getTabColor(0);
    _tabController.addListener(() {
      _setTabColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainCoursesList = widget.menuItemList
        .where((e) => e.itemType.toLowerCase() == 'main courses')
        .toList();
    final snacksList = widget.menuItemList
        .where((e) => e.itemType.toLowerCase() == 'snacks')
        .toList();
    final drinksList = widget.menuItemList
        .where((e) => e.itemType.toLowerCase() == 'drinks')
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                  Tab(text: 'Main Courses'),
                  Tab(text: 'Drinks'),
                  Tab(text: 'Snacks'),
                ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MenuItemList(
                  menuItemList: mainCoursesList,
                  addToCart: widget.addToCart,
                  removeFromCart: widget.removeFromCart,
                  onTap: onMenuItemTap,
                ),
                MenuItemList(
                  menuItemList: drinksList,
                  addToCart: widget.addToCart,
                  removeFromCart: widget.removeFromCart,
                  onTap: onMenuItemTap,
                ),
                MenuItemList(
                  menuItemList: snacksList,
                  addToCart: widget.addToCart,
                  removeFromCart: widget.removeFromCart,
                  onTap: onMenuItemTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
