import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/services/favorite_menu_item_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MenuItemListItem extends StatefulWidget {
  const MenuItemListItem({
    Key? key,
    required this.menuItem,
  }) : super(key: key);

  final MenuItem menuItem;

  @override
  State<MenuItemListItem> createState() => _MenuItemListItemState();
}

class _MenuItemListItemState extends State<MenuItemListItem> {
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

  _onFavoriteTab(int menuItemId) {
    final isFavorite = !_isFavorite;

    final favoriteMenuItemServices = FavoriteMenuItemServices();

    if (isFavorite) {
      favoriteMenuItemServices.addFavoriteMenuItem(menuItemId);
    } else {
      favoriteMenuItemServices.removeFavoriteMenuItem(menuItemId);
    }

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
    final menuItem = widget.menuItem;
    final jwtToken = UserServices.jwtToken;
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, menuItem.imagePath).toString();

    final double deviceWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
        width: deviceWidth - 20,
        height: 120,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {},
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(
                    imageUrl,
                    headers: {
                      'Authorization': 'Bearer $jwtToken',
                    },
                  ),
                  height: 100,
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
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: KColors.kPrimaryColor),
                  ),
                  Text(
                    '${menuItem.description}\n',
                    style: const TextStyle(fontSize: 12, color: KColors.kGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        menuItem.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 14, color: KColors.kLightTextColor),
                      ),
                      const SizedBox(width: 3),
                      RatingBarIndicator(
                        rating: menuItem.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemSize: 20,
                      )
                    ],
                  ),
                  Text(
                    '\$${menuItem.unitPrice.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: KColors.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    _onFavoriteTab(menuItem.id);
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: KColors.kPrimaryColor,
                    size: 26,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: KColors.kPrimaryColor,
                    size: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
