import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/merchant_rating_create_dto.dart';
import 'package:foodtogo_customers/models/dto/merchant_rating_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/merchant_rating_update_dto.dart';
import 'package:foodtogo_customers/models/merchant_rating.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class MerchantRatingServices {
  static const _apiUrl = 'api/MerchantRatingAPI';

  Future<double?> getAvgRating(int merchantId) async {
    const newApiUrl = '$_apiUrl/avgrating';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl, {
      'toMerchantId': merchantId.toString(),
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      return responseObject['result'].toDouble();
    }
    return null;
  }

  Future<List<MerchantRating>?> getAll({
    int? fromUserId,
    String? fromUserType,
    int? toMerchantId,
    int? orderId,
    double? minRating,
    int? pageSize,
    int? pageNumber,
  }) async {
    final dtoList = await getAllDTOs(
      fromUserId: fromUserId,
      fromUserType: fromUserType,
      toMerchantId: toMerchantId,
      orderId: orderId,
      minRating: minRating,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (dtoList == null) {
      return null;
    }

    List<MerchantRating> queryList = [];
    for (var dto in dtoList) {
      var merchantRating = MerchantRating(
        id: dto.id,
        fromUserId: dto.fromUserId,
        fromUserType: dto.fromUserType,
        toMerchantId: dto.toMerchantId,
        orderId: dto.orderId,
        rating: dto.rating,
      );

      queryList.add(merchantRating);
    }

    return queryList;
  }

  Future<List<MerchantRatingDTO>?> getAllDTOs({
    int? fromUserId,
    String? fromUserType,
    int? toMerchantId,
    int? orderId,
    double? minRating,
    int? pageSize,
    int? pageNumber,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    if (fromUserId != null) {
      queryParams['fromUserId'] = fromUserId.toString();
    }
    if (fromUserType != null) {
      queryParams['fromUserType'] = fromUserType;
    }
    if (toMerchantId != null) {
      queryParams['toMerchantId'] = toMerchantId.toString();
    }
    if (orderId != null) {
      queryParams['orderId'] = orderId.toString();
    }
    if (minRating != null) {
      queryParams['minRating'] = minRating.toString();
    }
    if (pageSize != null && pageNumber != null) {
      queryParams['pageSize'] = pageSize.toString();
      queryParams['pageNumber'] = pageNumber.toString();
    }

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode != 200) {
      log('MerchantRatingServices.getAllDTOs() responseJson.statusCode != 200');
      return null;
    }

    final responseData = json.decode(responseJson.body);
    final merchantRatingDTOList = (responseData['result'] as List)
        .map((json) => MerchantRatingDTO.fromJson(json))
        .toList();
    return merchantRatingDTOList;
  }

  Future<int> create(MerchantRatingCreateDTO createDTO) async {
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
      log('MerchantRatingServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return 0;
    }

    final responseData = json.decode(responseJson.body);

    final createdMerchantRatingId = responseData['result']['id'] as int;

    return createdMerchantRatingId;
  }

  Future<bool> update(int id, MerchantRatingUpdateDTO updateDTO) async {
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
}
