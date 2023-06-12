import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/menu_item_image_create_dto.dart';
import 'package:foodtogo_customers/models/dto/menu_item_image_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/menu_item_image_update_dto.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class MenuItemImageServices {
  static const apiUrl = 'api/MenuItemImageAPI';

  Future<MenuItemImageDTO?> getByMenuItem(int menuItemId) async {
    final newApiUrl = '$apiUrl/bymenuitem/$menuItemId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      return MenuItemImageDTO(
        id: responseData['result']['id'],
        menuItemId: responseData['result']['menuItemId'],
        path: responseData['result']['path'],
      );
    }
    return null;
  }

  Future<bool> create(MenuItemImageCreateDTO createDTO) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": createDTO.id,
      "menuItemId": createDTO.menuItemId,
      "path": createDTO.path,
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
    MenuItemImageUpdateDTO updateDTO,
    int id,
  ) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": id,
      "menuItemId": updateDTO.menuItemId,
      "path": updateDTO.path,
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
