import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/providers/favorite_merchant_list_provider.dart';
import 'package:foodtogo_customers/screens/merchant_screen.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/favorite_merchant_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantCardListItem extends ConsumerStatefulWidget {
  const MerchantCardListItem({
    Key? key,
    required this.merchant,
    required this.maxHeight,
  }) : super(key: key);

  final Merchant merchant;
  final double maxHeight;

  @override
  ConsumerState<MerchantCardListItem> createState() =>
      _MerchantCardListItemState();
}

class _MerchantCardListItemState extends ConsumerState<MerchantCardListItem> {
  bool _isFavorite = false;
  Timer? _initTimer;

  _initial(int merchantId) async {
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

  @override
  void initState() {
    super.initState();
    _initTimer = Timer.periodic(const Duration(microseconds: 100), (timer) {
      _initial(widget.merchant.merchantId);
      _initTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryServices = DeliveryServices();

    final maxHeight = widget.maxHeight;
    final merchant = widget.merchant;

    final merchantServices = MerchantServices();
    final distance = merchantServices.calDistance(
        merchant: merchant,
        startLongitude: UserServices.currentLongitude,
        startLatitude: UserServices.currentLatitude);
    final deliveryETA = deliveryServices.calDeliveryETA(distance);
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, merchant.imagePath).toString();
    final jwtToken = UserServices.jwtToken;

    return Row(
      children: [
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
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
              onTap: () {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MerchantScreen(merchant: merchant),
                    ),
                  );
                }
              },
              child: Container(
                width: 130,
                height: maxHeight - 30,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Hero(
                            tag: merchant.merchantId,
                            child: FadeInImage(
                              height: 65,
                              width: 110,
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${merchant.name}\n',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: KColors.kPrimaryColor, fontSize: 16),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${deliveryETA.toStringAsFixed(0)} min(s)',
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 22,
                                  ),
                                  Text(
                                    merchant.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: KColors.kLightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  _onFavoriteTab(merchant.merchantId);
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
                      ],
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
