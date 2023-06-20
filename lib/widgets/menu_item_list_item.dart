import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/providers/favorite_menu_item_list_provider.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/favorite_menu_item_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MenuItemListItem extends ConsumerStatefulWidget {
  const MenuItemListItem({
    Key? key,
    required this.menuItem,
    this.addToCart,
    this.removeFromCart,
  }) : super(key: key);

  final MenuItem menuItem;
  final Function(GlobalKey widgetKey, MenuItem menuItem)? addToCart;
  final Function(MenuItem menuItem)? removeFromCart;

  @override
  ConsumerState<MenuItemListItem> createState() => _MenuItemListItemState();
}

class _MenuItemListItemState extends ConsumerState<MenuItemListItem> {
  final GlobalKey itemAddToCartKey = GlobalKey();

  int _quantity = 0;
  bool _isFavorite = false;

  Timer? _initTimer;

  _initial(int menuItemId) async {
    final favoriteMenuItemServices = FavoriteMenuItemServices();
    final cartServices = CartServices();

    final results = await Future.wait([
      favoriteMenuItemServices.containsMenuItemId(menuItemId),
      cartServices.getQuantity(menuItemId)
    ]);

    final isFavorite = results[0] as bool;
    final quantity = results[1] as int;

    if (mounted) {
      setState(() {
        _quantity = quantity;
        _isFavorite = isFavorite;
      });
    }
  }

  _onFavoriteTab(int menuItemId) async {
    final isFavorite = !_isFavorite;

    final favoriteMenuItemServices = FavoriteMenuItemServices();

    if (isFavorite) {
      favoriteMenuItemServices.addFavoriteMenuItem(menuItemId);
    } else {
      favoriteMenuItemServices.removeFavoriteMenuItem(menuItemId);
    }

    final menuItemList =
        await favoriteMenuItemServices.getAllFavoriteMenuItems();
    ref.watch(favoriteMenuItemListProvider.notifier).update(menuItemList);
  }

  _getFavoriteStatus(int menuItemId) async {
    final favoriteMenuItemServices = FavoriteMenuItemServices();
    final isFavorite =
        await favoriteMenuItemServices.containsMenuItemId(menuItemId);

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  _setQuantity(int quantity) async {
    if (mounted) {
      setState(() {
        _quantity = quantity;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(microseconds: 100), (timer) {
      _initial(widget.menuItem.id);
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
    final menuItem = widget.menuItem;
    final jwtToken = UserServices.jwtToken;
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, menuItem.imagePath).toString();

    final double deviceWidth = MediaQuery.of(context).size.width;

    _getFavoriteStatus(menuItem.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: deviceWidth - 20,
          height: 145,
          decoration: BoxDecoration(
            color: KColors.kOnBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                key: itemAddToCartKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(
                      imageUrl,
                      headers: {
                        'Authorization': 'Bearer $jwtToken',
                      },
                    ),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: KColors.kPrimaryColor),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _onFavoriteTab(menuItem.id);
                          },
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: KColors.kPrimaryColor,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${menuItem.description}\n',
                      style:
                          const TextStyle(fontSize: 12, color: KColors.kGrey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          menuItem.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12.5, color: KColors.kLightTextColor),
                        ),
                        const SizedBox(width: 3),
                        RatingBarIndicator(
                          rating: menuItem.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemSize: 16,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${menuItem.unitPrice.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: KColors.kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity == 0) {
                                  return;
                                }
                                if (widget.addToCart != null) {
                                  widget.removeFromCart!(menuItem);
                                  _setQuantity(_quantity - 1);
                                }
                              },
                              icon: const Icon(
                                Icons.remove,
                                color: KColors.kPrimaryColor,
                                size: 26,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(3.0),
                                border:
                                    Border.all(color: KColors.kPrimaryColor),
                              ),
                              child: Text(
                                _quantity.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (widget.addToCart != null) {
                                  widget.addToCart!(itemAddToCartKey, menuItem);
                                  _setQuantity(_quantity + 1);
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: KColors.kPrimaryColor,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    )
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
