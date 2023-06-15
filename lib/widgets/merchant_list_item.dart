import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/providers/favorite_merchant_list_provider.dart';
import 'package:foodtogo_customers/screens/merchant_screen.dart';
import 'package:foodtogo_customers/services/favorite_merchant_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:foodtogo_customers/widgets/merchant_list.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantListItem extends ConsumerStatefulWidget {
  const MerchantListItem({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<MerchantListItem> createState() => _MerchantListItemState();
}

class _MerchantListItemState extends ConsumerState<MerchantListItem> {
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
  }

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
        startLongitude: UserServices.currentLongitude,
        startLatitude: UserServices.currentLatitude);

    final double deviceWidth = MediaQuery.of(context).size.width;

    _getFavoriteStatus(merchant.merchantId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: GestureDetector(
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
                child: Hero(
                  tag: merchant.merchantId,
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
                      merchant.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: KColors.kPrimaryColor),
                    ),
                    Text(
                      '${merchant.address}\n',
                      style:
                          const TextStyle(fontSize: 12, color: KColors.kGrey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              merchant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 14, color: KColors.kLightTextColor),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.star, color: Colors.amber),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      _onFavoriteTab(merchant.merchantId);
                    },
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: KColors.kPrimaryColor,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
