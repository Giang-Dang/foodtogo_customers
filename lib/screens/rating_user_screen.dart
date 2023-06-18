import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/dto/create_dto/user_rating_create_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/user_rating_update_dto.dart';
import 'package:foodtogo_customers/models/enum/user_type.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/user_rating_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class RatingUserScreen extends StatefulWidget {
  const RatingUserScreen({
    Key? key,
    required this.order,
    required this.fromUserType,
    required this.toUserType,
  }) : super(key: key);

  final Order order;
  final UserType fromUserType;
  final UserType toUserType;

  @override
  State<RatingUserScreen> createState() => _RatingUserScreenState();
}

class _RatingUserScreenState extends State<RatingUserScreen> {
  final UserRatingServices _userRatingServices = UserRatingServices();

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
    required UserType toUserType,
    required double rating,
  }) async {
    final queryResult = await _userRatingServices.getAll(
      fromUserId: _getId(order, fromUserType),
      fromUserType: fromUserType.name,
      toUserId: _getId(order, toUserType),
      toUserType: toUserType.name,
      orderId: order.id,
    );

    if (queryResult == null) {
      log('_RatingUserScreenState._onRatePressed() queryResult == null');
      return;
    }

    bool isExist = queryResult.isNotEmpty;

    bool isSuccess = false;

    if (isExist) {
      final updateDTO = UserRatingUpdateDTO(
          id: queryResult.first.id,
          fromUserId: queryResult.first.fromUserId,
          fromUserType: queryResult.first.fromUserType,
          toUserId: queryResult.first.toUserId,
          toUserType: queryResult.first.toUserType,
          orderId: queryResult.first.orderId,
          rating: rating);

      isSuccess =
          await _userRatingServices.update(queryResult.first.id, updateDTO);
    } else {
      final createDTO = UserRatingCreateDTO(
          id: 0,
          fromUserId: _getId(order, fromUserType),
          fromUserType: fromUserType.name,
          toUserId: _getId(order, toUserType),
          toUserType: toUserType.name,
          orderId: order.id,
          rating: rating);

      final response = await _userRatingServices.create(createDTO);

      isSuccess = (response != null);
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

  int _getId(Order order, UserType userType) {
    if (userType == UserType.Customer) {
      return order.customer.customerId;
    }
    if (userType == UserType.Shipper) {
      if (order.shipper == null) {
        log('_getId order.shipper == null');
        return 0;
      }
      return order.shipper!.userId;
    }
    if (userType == UserType.Merchant) {
      return order.merchant.userId; //must be a user Id for UserRating Table
    }
    return 0;
  }

  String _getName(Order order, UserType userType) {
    if (userType == UserType.Customer) {
      return '${order.customer.lastName} ${order.customer.middleName} ${order.customer.firstName}';
    }
    if (userType == UserType.Shipper) {
      if (order.shipper == null) {
        log('_getName order.shipper == null');
        return '';
      }
      return '${order.shipper!.lastName} ${order.shipper!.middleName} ${order.shipper!.firstName}';
    }
    if (userType == UserType.Merchant) {
      return order.merchant.name;
    }

    return '';
  }

  _initLoading(
    Order order,
    UserType fromUserType,
    UserType toUserType,
  ) async {
    final queryResult = await _userRatingServices.getAll(
      fromUserId: _getId(order, fromUserType),
      fromUserType: fromUserType.name,
      toUserId: _getId(order, toUserType),
      toUserType: toUserType.name,
      orderId: order.id,
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
      _initLoading(widget.order, widget.fromUserType, widget.toUserType);
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
          'Rating ${widget.toUserType.name}',
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getName(widget.order, widget.toUserType),
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
                    fromUserType: widget.fromUserType,
                    toUserType: widget.toUserType,
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
