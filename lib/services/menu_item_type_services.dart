import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/menu_item_type_create_dto.dart';
import 'package:foodtogo_customers/models/dto/menu_item_type_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/menu_item_type_update_dto.dart';
import 'package:foodtogo_customers/models/menu_item_type.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class MenuItemTypeServices {
  static const apiUrl = 'api/MenuItemTypeAPI';

  Future<List<MenuItemType>> getAll() async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final responseData = json.decode(responseJson.body);
    final menuItemTypeList = (responseData['result'] as List)
        .map((json) => MenuItemType.fromJson(json))
        .toList();
    return menuItemTypeList;
  }

  Future<List<MenuItemTypeDTO>> getAllDTOs() async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final responseData = json.decode(responseJson.body);
    final menuItemTypeList = (responseData['result'] as List)
        .map((json) => MenuItemTypeDTO.fromJson(json))
        .toList();
    return menuItemTypeList;
  }

  Future<MenuItemTypeDTO?> getByName(String name) async {
    final newApiUrl = '$apiUrl/byname/$name';
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final responseData = json.decode(responseJson.body);

    return MenuItemTypeDTO(
      id: responseData['result']['id'],
      name: responseData['result']['name'],
    );
  }

  Future<MenuItemTypeDTO?> getById(int id) async {
    final newApiUrl = '$apiUrl/$id';
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final responseData = json.decode(responseJson.body);

    return MenuItemTypeDTO(
      id: responseData['result']['id'],
      name: responseData['result']['name'],
    );
  }

  Future<bool> create(MenuItemTypeCreateDTO createDTO) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": createDTO.id,
      "name": createDTO.name,
    });

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode == HttpStatus.created) {
      return true;
    }
    return false;
  }

  Future<bool> update(
    MenuItemTypeUpdateDTO updateDTO,
    int id,
  ) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": updateDTO.id,
      "name": updateDTO.name,
    });

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

  Future<bool> delete(int id) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.noContent) {
      return true;
    }
    return false;
  }
}
