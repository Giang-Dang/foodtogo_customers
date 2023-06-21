import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/online_customer_location_create_dto.dart';
import 'package:foodtogo_customers/models/dto/online_customer_location_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/online_customer_location_update_dto.dart';
import 'package:foodtogo_customers/models/online_customer_location.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OnlineCustomerLocationServices {
  static const _apiUrl = 'api/OnlineCustomerLocationAPI';

  Future<OnlineCustomerLocation?> get(int customerId) async {
    final dto = await getDTO(customerId);

    if (dto == null) {
      log('OnlineCustomerLocationServices.get() dto == null');
      return null;
    }

    final onlineCustomerLocation = OnlineCustomerLocation(
        customerId: dto.customerId,
        geoLatitude: dto.geoLatitude,
        geoLongitude: dto.geoLongitude);

    return onlineCustomerLocation;
  }

  Future<OnlineCustomerLocationDTO?> getDTO(int customerId) async {
    final newApiUrl = '$_apiUrl/$customerId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final responseJson = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);
      final onlineCustomerLocationDTO =
          OnlineCustomerLocationDTO.fromJson(responseData['result']);
      return onlineCustomerLocationDTO;
    }

    return null;
  }

  Future<bool> create(OnlineCustomerLocationCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final jsonData = json.encode(createDTO.toJson());

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode != HttpStatus.created) {
      log('OnlineCustomerLocationServices create responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);
      return false;
    }

    return true;
  }

  Future<bool> update(int id, OnlineCustomerLocationUpdateDTO updateDTO) async {
    final newAPIUrl = '$_apiUrl/$id';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newAPIUrl);

    final jsonData = json.encode(updateDTO.toJson());

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode != HttpStatus.ok) {
      log('OnlineCustomerLocationServices update responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);
      return false;
    }

    return true;
  }

  Future<bool> delete(int userId) async {
    final newAPIUrl = '$_apiUrl/$userId';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newAPIUrl);

    final responseJson = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode != HttpStatus.noContent) {
      log('OnlineCustomerLocationServices.delete() responseJson.statusCode != HttpStatus.noContent');
      inspect(responseJson);
      return false;
    }

    return true;
  }
}
