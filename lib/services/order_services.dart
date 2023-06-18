import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/customer.dart';
import 'package:foodtogo_customers/models/dto/create_dto/order_create_dto.dart';
import 'package:foodtogo_customers/models/dto/order_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_customers/models/enum/order_status.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/models/shipper.dart';
import 'package:foodtogo_customers/services/customer_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/promotion_services.dart';
import 'package:foodtogo_customers/services/shipper_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OrderServices {
  static const _apiUrl = 'api/OrderAPI';

  Future<List<Order>?> getAll({
    int? merchantId,
    int? customerId,
    int? shipperId,
    int? promotionId,
    String? searchStatus,
    DateTime? searchPlacedDate,
    int? pageSize,
    int? pageNumber,
  }) async {
    final orderDTOList = await getAllDTOs(
      merchantId: merchantId,
      customerId: customerId,
      shipperId: shipperId,
      promotionId: promotionId,
      searchStatus: searchStatus,
      searchPlacedDate: searchPlacedDate,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    if (orderDTOList == null) {
      return null;
    }

    List<Order> ordersList = [];

    for (var orderDTO in orderDTOList) {
      var order = await get(orderDTO);
      if (order == null) {
        return null;
      }
      ordersList.add(order);
    }

    return ordersList;
  }

  Future<List<OrderDTO>?> getAllDTOs({
    int? merchantId,
    int? customerId,
    int? shipperId,
    int? promotionId,
    String? searchStatus,
    DateTime? searchPlacedDate,
    int? pageSize,
    int? pageNumber,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    if (merchantId != null) {
      queryParams['searchMerchantId'] = merchantId.toString();
    }
    if (customerId != null) {
      queryParams['searchCustomerId'] = customerId.toString();
    }
    if (shipperId != null) {
      queryParams['searchShipperId'] = shipperId.toString();
    }
    if (promotionId != null) {
      queryParams['searchPromotionId'] = promotionId.toString();
    }
    if (searchStatus != null) {
      queryParams['searchStatus'] = searchStatus;
    }
    if (searchPlacedDate != null) {
      queryParams['searchPlacedDate'] = searchPlacedDate.toString();
    }
    if (pageSize != null && pageNumber != null) {
      queryParams['pageSize'] = pageSize.toString();
      queryParams['pageNumber'] = pageNumber.toString();
    }

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final ordersList = (responseData['result'] as List)
          .map((json) => OrderDTO.fromJson(json))
          .toList();

      return ordersList;
    }

    return null;
  }

  Future<Order?> get(OrderDTO orderDTO) async {
    final MerchantServices merchantServices = MerchantServices();
    final CustomerServices customerServices = CustomerServices();
    final ShipperServices shipperServices = ShipperServices();
    final PromotionServices promotionServices = PromotionServices();

    final Merchant? merchant = await merchantServices.get(orderDTO.merchantId);
    final Customer? customer = await customerServices.get(orderDTO.customerId);
    Shipper? shipper;
    if (orderDTO.shipperId != null) {
      shipper = await shipperServices.get(orderDTO.shipperId!);
    }

    Promotion? promotion;
    if (orderDTO.promotionId != null) {
      promotion = await promotionServices.get(orderDTO.promotionId!);
    }

    if (merchant == null || customer == null) {
      return null;
    }

    Order order = Order(
      id: orderDTO.id,
      merchant: merchant,
      shipper: shipper,
      customer: customer,
      promotion: promotion,
      placedTime: orderDTO.placedTime,
      eta: orderDTO.eta,
      deliveryCompletionTime: orderDTO.deliveryCompletionTime,
      orderPrice: orderDTO.orderPrice,
      shippingFee: orderDTO.shippingFee,
      appFee: orderDTO.appFee,
      promotionDiscount: orderDTO.promotionDiscount,
      status: orderDTO.status,
      cancelledBy: orderDTO.cancelledBy,
      cancellationReason: orderDTO.cancellationReason,
      deliveryAddress: orderDTO.deliveryAddress,
      deliveryLatitude: orderDTO.deliveryLatitude,
      deliveryLongitude: orderDTO.deliveryLongitude,
    );

    return order;
  }

  //return created Order.id
  Future<int> create(OrderCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final requestBodyJson = json.encode(createDTO.toJson());

    final responseJson = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: requestBodyJson,
    );

    if (responseJson.statusCode != HttpStatus.created) {
      log('OrderServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return 0;
    }

    final responseData = json.decode(responseJson.body);

    final createdOrderId = responseData['result']['id'] as int;

    return createdOrderId;
  }

  Future<bool> update(int id, OrderUpdateDTO updateDTO) async {
    final newApiUrl = '$_apiUrl/$id';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final requestBodyJson = json.encode(updateDTO.toJson());

    final responseJson = await http.put(url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: requestBodyJson);

    if (responseJson.statusCode != HttpStatus.ok) {
      log('OrderServices.update() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return false;
    }

    return true;
  }

  Color getOrderColor(String orderStatus) {
    if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
      return KColors.kLightTextColor;
    }
    if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
      return KColors.kBlue;
    }
    if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
      return KColors.kBlue;
    }
    if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
      return KColors.kDanger;
    }
    return KColors.kTextColor;
  }

  String getOrderStatusInfo(String orderStatus) {
    if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
      return 'The order has been placed. Finding shipper...';
    }
    if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
      return 'Shipper is picking up the package.';
    }
    if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return 'Shipper is at the merchant';
    }
    if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
      return 'Shipper is delivering the package.';
    }
    if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
      return 'Shipper is at the delivery point';
    }
    if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
      return 'Order has been completed';
    }
    if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
      return 'Order has been cancelled';
    }
    return 'NA';
  }

  int getOrderStatusIndex(String orderStatus) {
    for (var value in OrderStatus.values) {
      if (orderStatus == value.name.toLowerCase()) {
        return value.index;
      }
    }
    log('OrderServices.getOrderStatusIndex() -1');
    return -1;
  }

  // Icon getOrderIcon(String orderStatus) {
  //   if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
  //     return Icons.sprint;
  //   }
  //   if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
  //     return Icons.sprint;
  //   }
  //   if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
  //     return KColors.kBlue;
  //   }
  //   if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
  //     return KColors.kDanger;
  //   }
  //   return KColors.kTextColor;
  // }
}
