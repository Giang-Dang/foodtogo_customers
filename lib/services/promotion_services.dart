import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/dto/create_dto/promotion_create_dto.dart';
import 'package:foodtogo_customers/models/dto/promotion_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/promotion_update_dto.dart';
import 'package:foodtogo_customers/models/promotion.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class PromotionServices {
  static const _apiUrl = 'api/PromotionAPI';

  Future<List<Promotion>?> getAll(int discountCreatorMerchantId) async {
    final promotionDTOsList = await getAllDTO(discountCreatorMerchantId);

    if (promotionDTOsList == null) {
      return null;
    }

    List<Promotion> promotionsList = [];

    for (var promotionDTO in promotionDTOsList) {
      Promotion promotion = Promotion(
          id: promotionDTO.id,
          discountCreatorMerchantId: promotionDTO.discountCreatorMerchantId,
          name: promotionDTO.name,
          description: promotionDTO.description,
          discountPercentage: promotionDTO.discountPercentage,
          discountAmount: promotionDTO.discountAmount,
          startDate: promotionDTO.startDate,
          endDate: promotionDTO.endDate,
          quantity: promotionDTO.quantity,
          quantityLeft: promotionDTO.quantityLeft);
      promotionsList.add(promotion);
    }

    return promotionsList;
  }

  Future<List<PromotionDTO>?> getAllDTO(int discountCreatorMerchantId) async {
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl, {
      'searchMerchantId': discountCreatorMerchantId.toString(),
    });

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final promotionDTOsList = (responseData['result'] as List)
          .map((json) => PromotionDTO.fromJson(json))
          .toList();

      return promotionDTOsList;
    }

    return null;
  }

  Future<Promotion?> get(int promotionId) async {
    final promotionDTO = await getDTO(promotionId);

    if (promotionDTO == null) {
      return null;
    }

    final promotion = Promotion(
      id: promotionId,
      discountCreatorMerchantId: promotionDTO.discountCreatorMerchantId,
      name: promotionDTO.name,
      discountPercentage: promotionDTO.discountPercentage,
      discountAmount: promotionDTO.discountAmount,
      startDate: promotionDTO.startDate,
      endDate: promotionDTO.endDate,
      quantity: promotionDTO.quantity,
      quantityLeft: promotionDTO.quantityLeft,
    );

    return promotion;
  }

  Future<PromotionDTO?> getDTO(int promotionId) async {
    final jwtToken = UserServices.jwtToken;
    final newApiUrl = '$_apiUrl/$promotionId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final promotionDTO = PromotionDTO.fromJson(responseData['result']);

      return promotionDTO;
    }

    return null;
  }

  Future<bool> create(PromotionCreateDTO createDTO) async {
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl);

    final createJson = json.encode({
      "id": 0,
      "discountCreatorMerchantId": createDTO.discountCreatorMerchantId,
      "name": createDTO.name,
      "description": createDTO.description,
      "discountPercentage": createDTO.discountPercentage,
      "discountAmount": createDTO.discountAmount,
      "startDate": createDTO.startDate.toString(),
      "endDate": createDTO.endDate.toString(),
    });

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: createJson,
    );

    inspect(responseJson);
    inspect(createDTO);

    if (responseJson.statusCode == HttpStatus.created) {
      return true;
    }

    log('create promotion failed!');

    return false;
  }

  Future<bool> update(int promotionId, PromotionUpdateDTO updateDTO) async {
    final newApiUrl = '$_apiUrl/$promotionId';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl);

    final updateJson = json.encode({
      "id": 0,
      "discountCreatorMerchantId": updateDTO.discountCreatorMerchantId,
      "name": updateDTO.name,
      "description": updateDTO.description,
      "discountPercentage": updateDTO.discountPercentage,
      "discountAmount": updateDTO.discountAmount,
      "startDate": updateDTO.startDate.toString(),
      "endDate": updateDTO.endDate.toString(),
      "quantity": 0,
      "quantityLeft": 0
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: updateJson,
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      return true;
    }

    log('update promotion failed!');
    inspect(url);
    inspect(updateJson);

    return false;
  }
}
