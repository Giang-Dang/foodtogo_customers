import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/screens/merchant_screen.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class PromotionListItem extends StatefulWidget {
  const PromotionListItem({
    Key? key,
    required this.promotion,
    required this.maxHeight,
  }) : super(key: key);

  final Promotion promotion;
  final double maxHeight;

  @override
  State<PromotionListItem> createState() => _PromotionListItemState();
}

class _PromotionListItemState extends State<PromotionListItem> {
  @override
  Widget build(BuildContext context) {
    final deliveryServices = DeliveryServices();
    final merchantServices = MerchantServices();

    const double cardWidth = 200.0;
    final double cardHeight = widget.maxHeight - 30;

    final merchant = widget.promotion.discountCreatorMerchant;
    final promotion = widget.promotion;

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
            borderRadius: BorderRadius.circular(15),
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MerchantScreen(merchant: merchant),
                  ));
                }
              },
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          promotion.name,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: KColors.kPrimaryColor,
                                    fontSize: 18,
                                  ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          merchant.name,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: KColors.kLightTextColor,
                                    fontSize: 14,
                                  ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13.0),
                          child: FadeInImage(
                            height: 118,
                            width: 180,
                            placeholder: MemoryImage(kTransparentImage),
                            image: NetworkImage(
                              imageUrl,
                              headers: {
                                'Authorization': 'Bearer $jwtToken',
                              },
                            ),
                            fit: BoxFit.fitWidth,
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
