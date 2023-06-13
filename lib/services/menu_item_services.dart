import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/menu_item_create_dto.dart';
import 'package:foodtogo_customers/models/dto/create_dto/menu_item_image_create_dto.dart';
import 'package:foodtogo_customers/models/dto/menu_item_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/menu_item_image_update_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/menu_item_update_dto.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/services/file_services.dart';
import 'package:foodtogo_customers/services/menu_item_image_services.dart';
import 'package:foodtogo_customers/services/menu_item_type_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class MenuItemServices {
  static const _apiUrl = 'api/MenuItemAPI';

  Future<List<MenuItem>?> getAll({
    int? searchMerchantId,
    String? searchName,
    int? searchItemTypeId,
    double? minRating,
    bool? isClosed,
    int? pageSize,
    int? pageNumber,
  }) async {
    final menuItemTypeServices = MenuItemTypeServices();
    final menuItemImageServices = MenuItemImageServices();

    final dtoList = await getAllDTOs(
      searchMerchantId: searchMerchantId,
      searchName: searchName,
      searchItemTypeId: searchItemTypeId,
      minRating: minRating,
      isClosed: isClosed,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    if (dtoList == null) {
      log('MenuItemServices.getAll() dtoList == null');
      return null;
    }

    List<MenuItem> menuItemList = [];

    for (var dto in dtoList) {
      var menuItemTypeDTO = await menuItemTypeServices.getById(dto.itemTypeId);
      var menuItemImageDTO = await menuItemImageServices.getByMenuItem(dto.id);

      if (menuItemTypeDTO == null || menuItemImageDTO == null) {
        log('MenuItemServices.getAll() menuItemTypeDTO == null || menuItemImageDTO == null');
        return null;
      }

      MenuItem menuItem = MenuItem(
        id: dto.id,
        merchantId: dto.merchantId,
        itemType: menuItemTypeDTO.name,
        name: dto.name,
        description: dto.description,
        unitPrice: dto.unitPrice,
        isClosed: dto.isClosed,
        imagePath: menuItemImageDTO.path,
        rating: dto.rating,
      );

      menuItemList.add(menuItem);
    }

    return menuItemList;
  }

  Future<List<MenuItemDTO>?> getAllDTOs({
    int? searchMerchantId,
    String? searchName,
    int? searchItemTypeId,
    double? minRating,
    bool? isClosed,
    int? pageSize,
    int? pageNumber,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    if (searchMerchantId != null) {
      queryParams['searchMerchantId'] = searchMerchantId.toString();
    }
    if (searchName != null) {
      queryParams['searchName'] = searchName;
    }
    if (searchItemTypeId != null) {
      queryParams['searchItemTypeId'] = searchItemTypeId.toString();
    }
    if (minRating != null) {
      queryParams['minRating'] = minRating.toString();
    }
    if (isClosed != null) {
      queryParams['isClosed'] = isClosed.toString();
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
      log('MenuItemServices.getAllDTOs() responseJson.statusCode != 200');
      return null;
    }

    final responseData = json.decode(responseJson.body);
    final menuItemList = (responseData['result'] as List)
        .map((json) => MenuItemDTO.fromJson(json))
        .toList();
    return menuItemList;
  }

  Future<List<MenuItem>?> getAllMenuItemsByMerchantId(int merchantId) async {
    final menuItemTypeServices = MenuItemTypeServices();
    final menuItemImageServices = MenuItemImageServices();
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(
      Secrets.kFoodToGoAPILink,
      _apiUrl,
      {
        'searchMerchantId': '$merchantId',
      },
    );

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final reponseData = jsonDecode(responseJson.body);

    final menuItemDTOList = (reponseData['result'] as List);

    if (menuItemDTOList.isEmpty) {
      return null;
    }

    List<MenuItem> menuItemList = [];

    for (var item in menuItemDTOList) {
      var itemId = item['id'];
      var itemTypeId = item['itemTypeId'];
      var menuType = await menuItemTypeServices.getById(itemTypeId);
      var menuItemImage = await menuItemImageServices.getByMenuItem(itemId);

      if (menuType == null || menuItemImage == null) {
        log("(menuType == null || menuItemImage == null) == true");
        return null;
      }
      var menuItem = MenuItem(
        id: itemId,
        merchantId: item['merchantId'],
        itemType: menuType.name,
        name: item['name'],
        description: item['description'],
        unitPrice: item['unitPrice'],
        isClosed: item['isClosed'],
        imagePath: menuItemImage.path,
        rating: item['rating'],
      );
      menuItemList.add(menuItem);
    }

    return menuItemList;
  }

  Future<MenuItem?> get(int menuItemId) async {
    final newApiUrl = '$_apiUrl/$menuItemId';
    final jwtToken = UserServices.jwtToken;

    final menuItemTypeServices = MenuItemTypeServices();
    final menuItemImageServices = MenuItemImageServices();

    final url = Uri.http(
      Secrets.kFoodToGoAPILink,
      newApiUrl,
    );

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final menuItemId = responseData['result']['id'];
      final menuItemTypeId = responseData['result']['itemTypeId'];

      final menuItemType = await menuItemTypeServices.getById(menuItemTypeId);
      final menuItemImage =
          await menuItemImageServices.getByMenuItem(menuItemId);

      if (menuItemImage == null || menuItemType == null) {
        return null;
      }

      final MenuItem menuItem = MenuItem(
        id: responseData['result']['id'],
        merchantId: responseData['result']['merchantId'],
        itemType: menuItemType.name,
        name: responseData['result']['name'],
        description: responseData['result']['description'],
        unitPrice: responseData['result']['unitPrice'],
        isClosed: responseData['result']['isClosed'],
        imagePath: menuItemImage.path,
        rating: responseData['result']['rating'],
      );

      return menuItem;
    }
    return null;
  }

  Future<bool> create(MenuItemCreateDTO createDTO, File image) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": createDTO.id,
      "merchantId": createDTO.merchantId,
      "itemTypeId": createDTO.itemTypeId,
      "name": createDTO.name,
      "description": createDTO.description,
      "unitPrice": createDTO.unitPrice,
    });

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);

    int menuItemId = 0;
    bool isUploadImageSuccess = false;

    if (responseObject['isSuccess'] as bool) {
      menuItemId = responseObject['result']['id'];
      isUploadImageSuccess = await uploadMenuItemImage(image, menuItemId);
    }

    if (responseJson.statusCode == HttpStatus.created && isUploadImageSuccess) {
      return true;
    }
    return false;
  }

  Future<bool> updateExcludeUploadImage(
    int id,
    MenuItemUpdateDTO updateDTO,
  ) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$_apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": id,
      "merchantId": updateDTO.merchantId,
      "itemTypeId": updateDTO.itemTypeId,
      "name": updateDTO.name,
      "description": updateDTO.description,
      "unitPrice": updateDTO.unitPrice,
      "isClosed": updateDTO.isClosed,
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );
    if (responseJson.statusCode != HttpStatus.ok) {
      return false;
    }
    return true;
  }

  Future<bool> update(
    int id,
    MenuItemUpdateDTO updateDTO,
    File? image,
  ) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, '$_apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": id,
      "merchantId": updateDTO.merchantId,
      "itemTypeId": updateDTO.itemTypeId,
      "name": updateDTO.name,
      "description": updateDTO.description,
      "unitPrice": updateDTO.unitPrice,
      "isClosed": updateDTO.isClosed,
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );
    if (responseJson.statusCode != HttpStatus.ok) {
      return false;
    }

    bool isUploadImageSuccess = true;
    if (image != null) {
      final responseObject = json.decode(responseJson.body);

      if (responseObject['isSuccess'] as bool) {
        final menuItemImageServices = MenuItemImageServices();
        final menuItemImage = await menuItemImageServices.getByMenuItem(id);

        if (menuItemImage == null) {
          log("MenuServices.update() : menuItemImage == null");
          return false;
        }
        isUploadImageSuccess = await uploadMenuItemImage(
          image,
          id,
          imageId: menuItemImage.id,
        );
      }
    }

    return isUploadImageSuccess;
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

    if (responseJson.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }

  Future<bool> uploadMenuItemImage(File image, int menuItemId,
      {int imageId = 0}) async {
    final fileServices = FileServices();
    final menuItemImageServices = MenuItemImageServices();
    //rename image to correct format
    final menuItemIdStr = menuItemId.toString().padLeft(7, '0');
    final datetime = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final fileExtention = path.extension(image.path);
    final newName = 'MenuItemImage_${menuItemIdStr}_$datetime$fileExtention';
    final renamedImage = await fileServices.renameFile(image, newName);

    final responsePath = await fileServices.uploadImage(renamedImage);
    final createDTO = MenuItemImageCreateDTO(
      id: imageId, //in case of updating
      menuItemId: menuItemId,
      path: responsePath,
    );

    if (imageId == 0) {
      await menuItemImageServices.create(createDTO);
    } else {
      //update
      final updateDTO = MenuItemImageUpdateDTO(
        id: imageId,
        menuItemId: createDTO.menuItemId,
        path: createDTO.path,
      );
      await menuItemImageServices.update(updateDTO, imageId);
    }

    return true;
  }
}
