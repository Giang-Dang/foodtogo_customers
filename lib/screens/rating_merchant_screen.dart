import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/dto/create_dto/merchant_rating_create_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/merchant_rating_update_dto.dart';
import 'package:foodtogo_customers/models/enum/user_type.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/merchant_rating_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class RatingMerchantScreen extends StatefulWidget {
  const RatingMerchantScreen({
    Key? key,
    required this.order,
    this.fromUserType = UserType.Customer,
  }) : super(key: key);

  final Order order;
  final UserType fromUserType;

  @override
  State<RatingMerchantScreen> createState() => _RatingMerchantScreenState();
}

class _RatingMerchantScreenState extends State<RatingMerchantScreen> {
  Timer? _initTimer;
  double _rating = 0.0;

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                onOkPressed();
              },
            ),
          ],
        );
      },
    );
  }

  _onRatePressed({
    required Order order,
    required UserType fromUserType,
    required int userId,
    required double rating,
  }) async {
    final merchantRatingServices = MerchantRatingServices();
    final queryResult = await merchantRatingServices.getAll(
      fromUserId: UserServices.userId,
      fromUserType: UserType.Customer.name,
      toMerchantId: order.merchant.merchantId,
      orderId: order.id,
      pageNumber: 1,
      pageSize: 1,
    );

    if (queryResult == null) {
      log('_RatingMerchantScreenState._onRatePressed() queryResult == null');
      return;
    }

    bool isExist = queryResult.isNotEmpty;

    bool isSuccess = false;

    if (isExist) {
      final updateDTO = MerchantRatingUpdateDTO(
        id: queryResult.first.id,
        fromUserId: queryResult.first.fromUserId,
        fromUserType: queryResult.first.fromUserType,
        toMerchantId: queryResult.first.toMerchantId,
        orderId: queryResult.first.orderId,
        rating: rating,
      );

      isSuccess =
          await merchantRatingServices.update(queryResult.first.id, updateDTO);
    } else {
      final createDTO = MerchantRatingCreateDTO(
        id: 0,
        fromUserId: UserServices.userId!,
        fromUserType: UserType.Customer.name,
        toMerchantId: order.merchant.merchantId,
        orderId: order.id,
        rating: rating,
      );

      final response = await merchantRatingServices.create(createDTO);

      isSuccess = (response != 0);
    }

    if (isSuccess) {
      _showAlertDialog('Rating Successed', 'Thank you for rating', () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
    } else {
      _showAlertDialog('Rating Failed',
          'Unable to collect your rating at the moment. Please try again later.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  _initLoading(Order order) async {
    final merchantRatingServices = MerchantRatingServices();
    final queryResult = await merchantRatingServices.getAll(
      fromUserId: UserServices.userId,
      fromUserType: UserType.Customer.name,
      toMerchantId: order.merchant.merchantId,
      orderId: order.id,
      pageNumber: 1,
      pageSize: 1,
    );

    if (queryResult == null) {
      log('_RatingUserScreenState._initLoading() queryResult == null');
      return;
    }

    if (queryResult.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _rating = queryResult.first.rating;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _initLoading(widget.order);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rating ${widget.order.merchant.name}',
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.order.merchant.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: KColors.kPrimaryColor, fontSize: 30),
            ),
            const SizedBox(height: 30.0),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 55,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 40.0),
            Text('Your rating: $_rating'),
            const SizedBox(height: 50.0),
            ElevatedButton(
              child: const Text('Rate'),
              onPressed: () {
                _onRatePressed(
                    order: widget.order,
                    fromUserType: UserType.Customer,
                    userId: UserServices.userId!,
                    rating: _rating);
              },
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
