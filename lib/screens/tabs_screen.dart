import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _selectedPageIndex = 0;
  Widget _activePage = const HomeWidget();
  bool _isAppBarShow = false;

  void _selectPage(int index) async {
    if (mounted) {
      setState(() {
        _selectedPageIndex = index;
        if (_selectedPageIndex == TabName.home.index) {
          _activePage = const HomeWidget();
          _isAppBarShow = false;
        } else if (_selectedPageIndex == TabName.orders.index) {
          _activePage = const Text('Orders screen');
          _isAppBarShow = true;
        } else if (_selectedPageIndex == TabName.favorites.index) {
          _activePage = const FavoriteWidget();
          _isAppBarShow = false;
        } else if (_selectedPageIndex == TabName.me.index) {
          _activePage = const Text('Me screen');
          _isAppBarShow = false;
        } else {
          _activePage = const HomeWidget();
          _isAppBarShow = false;
        }
      });
    }
  }

  _onFloatingActionButtonPressed() {}

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: appBar,
      body: _activePage,
      floatingActionButton: _selectedPageIndex == 0
          ? SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _onFloatingActionButtonPressed,
                elevation: 10.0,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
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
    );
  }
}
