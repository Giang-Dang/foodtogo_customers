import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/providers/favorite_menu_item_list_provider.dart';
import 'package:foodtogo_customers/services/favorite_menu_item_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MenuItemCardListItem extends ConsumerStatefulWidget {
  const MenuItemCardListItem({
    Key? key,
    required this.menuItem,
    required this.maxHeight,
  }) : super(key: key);

  final MenuItem menuItem;
  final double maxHeight;

  @override
  ConsumerState<MenuItemCardListItem> createState() =>
      _MenuItemCardListItemState();
}

class _MenuItemCardListItemState extends ConsumerState<MenuItemCardListItem> {
  bool _isFavorite = false;
  Timer? _initTimer;

  _initial(int menuItemId) async {
    final favoriteMenuItemServices = FavoriteMenuItemServices();
    final isFavorite =
        await favoriteMenuItemServices.containsMenuItemId(menuItemId);

    if (mounted) {
      setState(() {
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

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
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
    final maxHeight = widget.maxHeight;
    final menuItem = widget.menuItem;

    final double containerHeight = maxHeight - 30;
    final double containerWidth = 140;

    final jwtToken = UserServices.jwtToken;

    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, menuItem.imagePath).toString();

    return Row(
      children: [
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            color: KColors.kOnBackgroundColor,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Container(
                width: containerWidth,
                height: containerHeight,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FadeInImage(
                        height: 80,
                        width: containerWidth - 20,
                        placeholder: MemoryImage(kTransparentImage),
                        image: NetworkImage(
                          imageUrl,
                          headers: {
                            'Authorization': 'Bearer $jwtToken',
                          },
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menuItem.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: KColors.kPrimaryColor, fontSize: 15),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${menuItem.description}\n',
                      style:
                          const TextStyle(fontSize: 11, color: KColors.kGrey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -2),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.translate(
                            offset: const Offset(10, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                                Text(
                                  menuItem.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: KColors.kLightTextColor,
                                  ),
                                ),
                              ],
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
                              color: KColors.kPrimaryColor.withOpacity(0.7),
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      '${menuItem.unitPrice.toStringAsFixed(1)} \$',
                      style: TextStyle(
                          fontSize: 16,
                          color: KColors.kPrimaryColor.withOpacity(0.9),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
