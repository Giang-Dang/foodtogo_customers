import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/merchant_list.dart';

class NearbyMerchantsWidget extends StatefulWidget {
  const NearbyMerchantsWidget({Key? key}) : super(key: key);

  @override
  State<NearbyMerchantsWidget> createState() => _NearbyMerchantsWidgetState();
}

class _NearbyMerchantsWidgetState extends State<NearbyMerchantsWidget> {
  List<Merchant> _nearbyMerchantList = [];
  bool _isLoading = true;

  Timer? _initTimer;

  _getNearbyMerchantList({required double nearbyDistance}) async {
    final merchantServices = MerchantServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final nearbyMerchantList = await merchantServices.getAllMerchants(
        startLatitude: UserServices.currentLatitude,
        startLongitude: UserServices.currentLongitude,
        searchDistanceInKm: nearbyDistance);

    if (mounted) {
      setState(() {
        _nearbyMerchantList = nearbyMerchantList;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _getNearbyMerchantList(nearbyDistance: 10);
      _initTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget merchantListcontain = const Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
        ],
      ),
    );
    if (!_isLoading) {
      merchantListcontain = Row(
        children: [
          MerchantList(merchantList: _nearbyMerchantList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 5),
          child: Text(
            "Nearby Merchants",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: KColors.kTextColor),
            textAlign: TextAlign.start,
          ),
        ),
        merchantListcontain,
      ],
    );
  }
}
