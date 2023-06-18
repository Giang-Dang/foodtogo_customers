import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/user_rating_create_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/user_rating_update_dto.dart';
import 'package:foodtogo_customers/models/dto/user_rating_dto.dart';
import 'package:foodtogo_customers/models/user_rating.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class UserRatingServices {
  static const _apiUrl = 'api/UserRatingAPI';
  Future<double?> getAvgRating(int userId, String asType) async {
    const newApiUrl = '$_apiUrl/avgrating';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl, {
      'toUserId': userId.toString(),
      'asType': asType,
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

  Future<List<UserRating>?> getAll({
    int? fromUserId,
    String? fromUserType,
    int? toUserId,
    String? toUserType,
    int? orderId,
    double? rating,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final dtoList = await getAllDTOs(
      fromUserId: fromUserId,
      fromUserType: fromUserType,
      toUserId: toUserId,
      toUserType: toUserType,
      rating: rating,
      orderId: orderId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (dtoList == null) {
      log('UserRatingServices.getAll() dtoList == null');

      return null;
    }

    List<UserRating> resultList = [];
    for (var dto in dtoList) {
      var userRating = UserRating(
          id: dto.id,
          fromUserId: dto.fromUserId,
          fromUserType: dto.fromUserType,
          toUserId: dto.toUserId,
          toUserType: dto.toUserType,
          orderId: dto.orderId,
          rating: dto.rating);

      resultList.add(userRating);
    }

    return resultList;
  }

  Future<List<UserRatingDTO>?> getAllDTOs({
    int? fromUserId,
    String? fromUserType,
    int? toUserId,
    String? toUserType,
    int? orderId,
    double? rating,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    queryParams.addAll({
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    });

    if (fromUserId != null) {
      queryParams['fromUserId'] = fromUserId.toString();
    }
    if (fromUserType != null) {
      queryParams['fromUserType'] = fromUserType;
    }
    if (toUserId != null) {
      queryParams['toUserId'] = toUserId.toString();
    }
    if (toUserType != null) {
      queryParams['toUserType'] = toUserType;
    }
    if (orderId != null) {
      queryParams['orderId'] = orderId.toString();
    }
    if (rating != null) {
      queryParams['rating'] = rating.toString();
    }

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode != HttpStatus.ok) {
      log('UserRatingServices.getAllDTOs() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return null;
    }

    final responseData = json.decode(responseJson.body);

    final resultList = (responseData['result'] as List)
        .map((json) => UserRatingDTO.fromJson(json))
        .toList();

    return resultList;
  }

  Future<UserRatingDTO?> create(UserRatingCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final requestJson = json.encode(createDTO.toJson());

    final responseJson = await http.post(url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: requestJson);

    if (responseJson.statusCode != HttpStatus.created) {
      log('UserRatingServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return null;
    }

    final responseData = json.decode(responseJson.body);

    final result = UserRatingDTO.fromJson(responseData['result']);

    return result;
  }

  Future<bool> update(int id, UserRatingUpdateDTO updateDTO) async {
    final newApiUrl = '$_apiUrl/$id';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final requestJson = json.encode(updateDTO.toJson());

    final responseJson = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: requestJson,
    );

    if (responseJson.statusCode != HttpStatus.ok) {
      log('UserRatingServices.update() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return false;
    }

    return true;
  }
}
