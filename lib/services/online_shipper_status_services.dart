import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/online_shipper_status_create_dto.dart';
import 'package:foodtogo_customers/models/dto/online_shipper_status_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/online_shipper_status_update_dto.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OnlineShipperStatusServices {
  static const _apiUrl = 'api/OnlineShipperStatusAPI';

  Future<int> create(OnlineShipperStatusCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final requestJsonBody = json.encode(createDTO.toJson());

    final responseJson = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: requestJsonBody,
    );

    if (responseJson.statusCode != HttpStatus.created) {
      log('MerchantRatingServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return 0;
    }

    final responseData = json.decode(responseJson.body);

    final createId = responseData['result']['shipperId'] as int;

    return createId;
  }

  Future<bool> update(int id, OnlineShipperStatusUpdateDTO updateDTO) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$_apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode(updateDTO.toJson());

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }

  Future<OnlineShipperStatusDTO?> getDTO(int shipperId) async {
    final newApiUrl = '$_apiUrl/$shipperId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final responseJson = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (responseJson.statusCode != HttpStatus.ok) {
      log('OnlineShipperStatusServices.getDTO() responseJson.statusCode != HttpStatus.ok');
      return null;
    }

    final responseData = json.decode(responseJson.body);
    final dto = OnlineShipperStatusDTO.fromJson(responseData['result']);
    return dto;
  }

  Future<bool> delete(int id) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$_apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode != HttpStatus.noContent) {
      log('OnlineShipperStatusServices.delete responseJson.statusCode != HttpStatus.noContent');
      return false;
    }
    return true;
  }
}
