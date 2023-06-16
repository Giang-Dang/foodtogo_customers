import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/customer.dart';
import 'package:foodtogo_customers/models/dto/user_dto.dart';
import 'package:foodtogo_customers/services/customer_services.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class CheckoutDeliveryAddress extends StatefulWidget {
  const CheckoutDeliveryAddress({
    Key? key,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.setDeliveryLocation,
  }) : super(key: key);

  final double deliveryLongitude;
  final double deliveryLatitude;

  final Function({
    required double newDeliveryLongitude,
    required double newDeliveryLatitude,
    required String newDeliveryAddress,
  }) setDeliveryLocation;

  @override
  State<CheckoutDeliveryAddress> createState() =>
      _CheckoutDeliveryAddressState();
}

class _CheckoutDeliveryAddressState extends State<CheckoutDeliveryAddress> {
  Customer? _currentCustomer;
  String? _deliveryAddress;

  Timer? _initTimer;

  _getCurrentCustomer() async {
    if (_currentCustomer != null) {
      return;
    }

    final customerServices = CustomerServices();

    final currentCustomer = await customerServices.get(UserServices.userId!);

    if (mounted) {
      setState(() {
        _currentCustomer = currentCustomer;
      });
    }
  }

  _getDeliveryAddress(double deliveryLatitude, double deliveryLongitude) async {
    final locationServices = LocationServices();

    final deliveryAddress =
        await locationServices.getAddress(deliveryLatitude, deliveryLongitude);

    if (deliveryAddress != _deliveryAddress) {
      if (mounted) {
        setState(() {
          _deliveryAddress = deliveryAddress;
        });
      }
    }
  }

  _initialize() async {
    await _getCurrentCustomer();
    await _getDeliveryAddress(
        widget.deliveryLatitude, widget.deliveryLongitude);

    widget.setDeliveryLocation(
        newDeliveryAddress: _deliveryAddress ?? '',
        newDeliveryLatitude: widget.deliveryLatitude,
        newDeliveryLongitude: widget.deliveryLongitude);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
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
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
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
      ),
      child: Column(
        children: [
          Container(
            color: KColors.kOnBackgroundColor,
            width: deviceWidth,
            padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(2, 2, 0, 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pin_drop_outlined,
                              color: KColors.kPrimaryColor,
                              size: 17,
                            ),
                            Text(
                              'Delivery Address:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: KColors.kTextColor,
                                    fontSize: 15,
                                  ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                      if (_currentCustomer != null)
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 2, 0, 5),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Text(
                                    '${_currentCustomer!.lastName} ${_currentCustomer!.middleName} ${_currentCustomer!.firstName}'),
                                const VerticalDivider(
                                  color: KColors.kGrey,
                                ),
                                Text(_currentCustomer!.phoneNumber),
                              ],
                            ),
                          ),
                        ),
                      if (_deliveryAddress != null)
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 2, 0, 5),
                          child: Text(
                            _deliveryAddress!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.navigate_next))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
