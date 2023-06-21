import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/dto/create_dto/normal_open_hours_create_dto.dart';
import 'package:foodtogo_customers/models/dto/normal_open_hours_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/normal_open_hours_update_dto.dart';
import 'package:foodtogo_customers/models/normal_open_hours.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class NormalOpenHoursServices {
  static const _apiUrl = 'api/NormalOpenHoursAPI';

  Future<List<NormalOpenHours>?> getAll({
    int? searchMerchantId,
    int? searchDayOfWeek,
    int? searchSessionNo,
    TimeOfDay? searchOpenTime,
    TimeOfDay? searchCloseTime,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final dtosList = await getAllDTOs(
      searchMerchantId: searchMerchantId,
      searchDayOfWeek: searchDayOfWeek,
      searchSessionNo: searchSessionNo,
      searchOpenTime: searchOpenTime,
      searchCloseTime: searchCloseTime,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    if (dtosList == null) {
      log('NormalOpenHoursServices.getAll() dtosList == null');
      return null;
    }

    final List<NormalOpenHours> resultList = [];
    for (var dto in dtosList) {
      NormalOpenHours normalOpenHours = NormalOpenHours(
        id: dto.id,
        merchantId: dto.merchantId,
        dayOfWeek: dto.dayOfWeek,
        sessionNo: dto.sessionNo,
        openTime: dto.openTime,
        closeTime: dto.closeTime,
      );

      resultList.add(normalOpenHours);
    }

    return resultList;
  }

  Future<List<NormalOpenHoursDTO>?> getAllDTOs({
    int? searchMerchantId,
    int? searchDayOfWeek,
    int? searchSessionNo,
    TimeOfDay? searchOpenTime,
    TimeOfDay? searchCloseTime,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    queryParams.addAll({
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    });

    if (searchMerchantId != null) {
      queryParams['searchMerchantId'] = searchMerchantId.toString();
    }

    if (searchDayOfWeek != null) {
      queryParams['searchDayOfWeek'] = searchDayOfWeek.toString();
    }

    if (searchSessionNo != null) {
      queryParams['searchSessionNo'] = searchSessionNo.toString();
    }

    if (searchOpenTime != null) {
      final now = DateTime.now();
      final searchOpenDateTime = DateTime(now.year, now.month, now.day,
          searchOpenTime.hour, searchOpenTime.minute);

      queryParams['searchOpenTime'] = searchOpenDateTime.toString();
    }

    if (searchCloseTime != null) {
      final now = DateTime.now();
      final searchCloseDateTime = DateTime(now.year, now.month, now.day,
          searchCloseTime.hour, searchCloseTime.minute);

      queryParams['searchOpenTime'] = searchCloseDateTime.toString();
    }

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode != HttpStatus.ok) {
      log('NormalOpenHoursServices.GetAllDTOs() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return null;
    }

    final responseData = json.decode(responseJson.body);

    final resultList = (responseData['result'] as List)
        .map((json) => NormalOpenHoursDTO.fromJson(json))
        .toList();

    return resultList;
  }

  Future<bool> delete(int id) async {
    final newAPIUrl = '$_apiUrl/$id';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newAPIUrl);

    final responseJson = await http.delete(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode != HttpStatus.noContent) {
      return false;
    }

    return true;
  }

  Future<NormalOpenHours?> create(NormalOpenHoursCreateDTO createDTO) async {
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
      log('NormalOpenHoursServices.create()');
      inspect(responseJson);

      return null;
    }

    final responseData = json.decode(responseJson.body);

    final result = NormalOpenHours.fromJson(responseData['result']);

    return result;
  }

  Future<bool> update(int id, NormalOpenHoursUpdateDTO updateDTO) async {
    final jwtToken = UserServices.jwtToken;

    final newApiUrl = '$_apiUrl/$id';

    final requestJson = json.encode(updateDTO.toJson());

    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final responseJson = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: requestJson);

    if (responseJson.statusCode != HttpStatus.ok) {
      log('NormalOpenHoursServices.update()');
      inspect(responseJson);

      return false;
    }

    return true;
  }
}
