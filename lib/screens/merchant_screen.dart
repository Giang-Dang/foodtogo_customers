import 'dart:async';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/providers/favorite_merchant_list_provider.dart';
import 'package:foodtogo_customers/services/cart_services.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/favorite_merchant_services.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:foodtogo_customers/widgets/menu_item_list.dart';
import 'package:foodtogo_customers/widgets/merchant_menu_item_list.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantScreen extends ConsumerStatefulWidget {
  const MerchantScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<MerchantScreen> createState() => _MerchantWidgetState();
}

class _MerchantWidgetState extends ConsumerState<MerchantScreen> {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var _cartQuantityItems = 0;

  bool _isFavorite = false;
  bool _isInitializing = true;

  Timer? _initTimer;

  List<MenuItem> _menuItemList = [];

  _getFavoriteStatus(int merchantId) async {
    final favoriteMerchantServices = FavoriteMerchantServices();
    final isFavorite =
        await favoriteMerchantServices.containsMerchantId(merchantId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  _onFavoriteTab(int merchantId) async {
    final isFavorite = !_isFavorite;

    final favoriteMerchantServices = FavoriteMerchantServices();

    if (isFavorite) {
      favoriteMerchantServices.addFavoriteMerchant(merchantId);
    } else {
      favoriteMerchantServices.removeFavoriteMerchant(merchantId);
    }

    final merchantList = await favoriteMerchantServices.getAllMerchants();
    ref.watch(favoriteMerchantListProvider.notifier).update(merchantList);

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  _getMenuItemList(int merchantId) async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    final menuItemServices = MenuItemServices();

    final menuItemList =
        await menuItemServices.getAll(searchMerchantId: merchantId);

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _menuItemList = menuItemList ?? [];
      });
    }
  }

  addToCart(GlobalKey widgetKey, MenuItem menuItem) async {
    final cartServices = CartServices();
    int quantity = await cartServices.getQuantity(menuItem.id);
    bool isAddingSuccess =
        await cartServices.addMenuItem(menuItem, quantity + 1);

    if (isAddingSuccess) {
      //animation
      await runAddToCartAnimation(widgetKey);
      await cartKey.currentState!
          .runCartAnimation((++_cartQuantityItems).toString());
    }
  }

  _setCartQuantity() async {
    final cartServices = CartServices();
    int totalQuantity = await cartServices.getTotalQuantity();
    if (cartKey.currentState != null) {
      await cartKey.currentState!.updateBadge(totalQuantity.toString());
    }
  }

  _initial(int merchantId) {
    _getMenuItemList(merchantId);
  }

  _onFloatingActionButtonPressed() {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(microseconds: 100), (timer) {
      _initial(widget.merchant.merchantId);
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
    final merchantServices = MerchantServices();
    final merchant = widget.merchant;
    final jwtToken = UserServices.jwtToken;
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, merchant.imagePath).toString();
    final distance = merchantServices.calDistance(
      merchant: merchant,
      startLatitude: UserServices.currentLatitude,
      startLongitude: UserServices.currentLongitude,
    );

    final deliveryServices = DeliveryServices();
    final etaTime = deliveryServices.calDeliveryETA(distance);

    final double deviceWidth = MediaQuery.of(context).size.width;

    _getFavoriteStatus(merchant.merchantId);
    _setCartQuantity();

    Widget menuItemListContent = const Center(
      child: CircularProgressIndicator(),
    );

    if (!_isInitializing) {
      menuItemListContent = MerchantMenuItemList(
        menuItemList: _menuItemList,
        addToCart: addToCart,
      );
    }

    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.9,
      dragAnimation: const DragToCartAnimationOptions(
          duration: Duration(milliseconds: 500)),
      jumpAnimation:
          const JumpAnimationOptions(duration: Duration(milliseconds: 200)),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            onPressed: _onFloatingActionButtonPressed,
            elevation: 10.0,
            shape: const CircleBorder(),
            child: AddToCartIcon(
              key: cartKey,
              badgeOptions: const BadgeOptions(
                active: true,
                backgroundColor: KColors.kPrimaryColor,
                foregroundColor: KColors.kBackgroundColor,
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              color: KColors.kBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Hero(
                      tag: merchant.merchantId,
                      child: FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        image: NetworkImage(
                          imageUrl,
                          headers: {
                            'Authorization': 'Bearer $jwtToken',
                          },
                        ),
                        width: deviceWidth,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: KColors.kOnBackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  '${merchant.name}\n',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: KColors.kTextColor),
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RatingBarIndicator(
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        merchant.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: KColors.kLightTextColor,
                                        ),
                                      ),
                                      const VerticalDivider(
                                          color: KColors.kGrey),
                                      const Icon(Icons.schedule, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${etaTime.toStringAsFixed(0)} min(s)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: KColors.kLightTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.info_outline,
                                    color: KColors.kLightTextColor),
                              ),
                              IconButton(
                                onPressed: () {
                                  _onFavoriteTab(merchant.merchantId);
                                },
                                icon: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: KColors.kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    menuItemListContent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
