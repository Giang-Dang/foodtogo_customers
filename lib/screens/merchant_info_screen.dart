import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/normal_open_hours.dart';
import 'package:foodtogo_customers/services/delivery_services.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/normal_open_hours_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/merchant_info_open_hours.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.myapp/map');

class MerchantInfoScreen extends StatelessWidget {
  const MerchantInfoScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  String get _locationImage {
    final locationServices = LocationServices();

    final lat = merchant.geoLatitude;
    final lng = merchant.geoLongitude;

    return locationServices.getlocationImageUrl(lat, lng, 18);
  }

  _launchMap(double lat, double lng) async {
    try {
      await platform.invokeMethod('launchMap', {'lat': lat, 'lng': lng});
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchantServices = MerchantServices();
    final deliveryServices = DeliveryServices();

    final distance = merchantServices.calDistance(
      merchant: merchant,
      startLatitude: UserServices.currentLatitude,
      startLongitude: UserServices.currentLongitude,
    );

    final etaTime = deliveryServices.calDeliveryETA(distance);

    final double deviceWidth = MediaQuery.sizeOf(context).width;
    final double deviceHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Information',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: KColors.kTextColor,
                fontSize: 20,
              ),
        ),
      ),
      body: Container(
        color: KColors.kBackgroundColor,
        width: deviceWidth,
        height: deviceHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Merchant general info
              Container(
                width: deviceWidth,
                height: 125,
                color: KColors.kOnBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: deviceWidth - 100,
                            child: Text(
                              '${merchant.name}\n',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: KColors.kTextColor,
                                    fontSize: 24,
                                  ),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: merchant.rating,
                                  itemBuilder: (context, index) => const Icon(
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
                                const VerticalDivider(color: KColors.kGrey),
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
                  ],
                ),
              ),

              //Map location Image & address
              Container(
                width: deviceWidth,
                height: deviceWidth / 2,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _launchMap(
                          merchant.geoLatitude,
                          merchant.geoLongitude,
                        );
                      },
                      child: Container(
                        width: deviceWidth,
                        height: deviceWidth / 2,
                        child: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: NetworkImage(_locationImage),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 44,
                        ),
                        child: Text(
                          merchant.address,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: KColors.kOnBackgroundColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //Open hours
              Container(
                  color: KColors.kBackgroundColor,
                  child: MerchantInfoOpenHours(merchant: merchant)),
            ],
          ),
        ),
      ),
    );
  }
}
