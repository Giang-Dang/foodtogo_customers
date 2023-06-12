import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantListItem extends StatefulWidget {
  const MerchantListItem({
    Key? key,
    required this.merchant,
    required this.maxHeight,
  }) : super(key: key);

  final Merchant merchant;
  final double maxHeight;

  @override
  State<MerchantListItem> createState() => _MerchantListItemState();
}

class _MerchantListItemState extends State<MerchantListItem> {
  @override
  void initState() {
    super.initState();
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
              onTap: () {},
              child: Container(
                width: 130,
                height: maxHeight - 30,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(height: 4),
                        Text(
                          '${merchant.name}\n',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: KColors.kPrimaryColor, fontSize: 15),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        RatingBarIndicator(
                          rating: merchant.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 15,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(height: 2),
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
                        )
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
