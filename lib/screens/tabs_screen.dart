import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodtogo_customers/screens/cart_screen.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/online_customer_location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/favorite_widget.dart';
import 'package:foodtogo_customers/widgets/home_widget.dart';

enum TabName { home, orders, favorites, me }

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  DateTime _timeBackPressed = DateTime.now();
  int _selectedPageIndex = 0;
  int _totalItemQuantityInCart = 0;

  Widget _activePage = const HomeWidget();
  bool _isAppBarShow = false;
  bool _isFloatingButtonShow = true;

  Timer? _initTimer;

  _deleteLocation() async {
    final onlineCustomerLocationServices = OnlineCustomerLocationServices();
    int userId = UserServices.userId ?? 0;
    if (userId != 0) {
      await onlineCustomerLocationServices.delete(userId);
      log('didChangeAppLifecycleState complete');
    }
  }

  void _selectPage(int index) async {
    if (mounted) {
      setState(() {
        _selectedPageIndex = index;
        if (_selectedPageIndex == TabName.home.index) {
          _activePage = const HomeWidget();
          _isAppBarShow = false;
          _isFloatingButtonShow = true;
        } else if (_selectedPageIndex == TabName.orders.index) {
          _activePage = const Text('Orders screen');
          _isAppBarShow = true;
          _isFloatingButtonShow = false;
        } else if (_selectedPageIndex == TabName.favorites.index) {
          _activePage = const FavoriteWidget();
          _isAppBarShow = false;
          _isFloatingButtonShow = true;
        } else if (_selectedPageIndex == TabName.me.index) {
          _activePage = const Text('Me screen');
          _isAppBarShow = false;
          _isFloatingButtonShow = false;
        } else {
          _activePage = const HomeWidget();
          _isAppBarShow = false;
          _isFloatingButtonShow = false;
        }
      });
    }
  }

  _getTotalItemQuantityInCart() async {
    final cartServices = CartServices();

    final totalQuantity = await cartServices.getTotalQuantity();


    if (mounted) {
      setState(() {
        _totalItemQuantityInCart = totalQuantity;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final difference = DateTime.now().difference(_timeBackPressed);
    final isExitWarning = difference >= const Duration(seconds: 2);

    _timeBackPressed = DateTime.now();

    if (isExitWarning) {
      const message = 'Press back again to exit';
      Fluttertoast.showToast(msg: message, fontSize: 18);

      return false;
    } else {
      Fluttertoast.cancel();

      const message = 'Exiting the app. Please wait...';
      Fluttertoast.showToast(msg: message, fontSize: 18);

      await _deleteLocation();

      Fluttertoast.cancel();

      return true;
    }
  }

  _onFloatingActionButtonPressed() {
    if (context.mounted) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CartScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getTotalItemQuantityInCart();

    AppBar? appBar = !_isAppBarShow
        ? null
        : AppBar(
            backgroundColor: KColors.kBackgroundColor,
            title: Text(
              'FoodToGo - Customer',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 24,
                  ),
            ),
          );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: _activePage,
        floatingActionButton: _isFloatingButtonShow
            ? Stack(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      onPressed: _onFloatingActionButtonPressed,
                      elevation: 10.0,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 3,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: KColors.kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$_totalItemQuantityInCart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: KColors.kLightTextColor,
          unselectedFontSize: 10,
          selectedItemColor: KColors.kPrimaryColor,
          selectedFontSize: 12,
          showUnselectedLabels: true,
          currentIndex: _selectedPageIndex,
          onTap: (index) {
            _selectPage(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.restaurant,
                color: KColors.kLightTextColor,
              ),
              label: 'Home',
              activeIcon: Icon(
                Icons.restaurant,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: KColors.kLightTextColor,
              ),
              label: 'Orders',
              activeIcon: Icon(
                Icons.receipt_long_outlined,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_outline,
                color: KColors.kLightTextColor,
              ),
              label: 'Favorites',
              activeIcon: Icon(
                Icons.favorite,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color: KColors.kLightTextColor,
              ),
              label: 'Me',
              activeIcon: Icon(
                Icons.person,
                color: KColors.kPrimaryColor,
              ),
              backgroundColor: KColors.kOnBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
