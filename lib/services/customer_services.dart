import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_customers/models/customer.dart';
import 'package:foodtogo_customers/models/dto/create_dto/customer_create_dto.dart';
import 'package:foodtogo_customers/models/dto/customer_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/customer_update_dto.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class CustomerServices {
  static const _apiUrl = 'api/CustomerAPI';

  Future<Customer?> get(int customerId) async {
    final dto = await getDTO(customerId);

    if (dto == null) {
      log('CustomerServices.get() dto == null');
      return null;
    }

    final userServices = UserServices();
    final userDTO = await userServices.getDTO(customerId);

    if (userDTO == null) {
      log('CustomerServices.get() userDTO == null');
      return null;
    }

    final Customer customer = Customer(
      customerId: dto.customerId,
      firstName: dto.firstName,
      lastName: dto.lastName,
      middleName: dto.middleName,
      address: dto.address,
      phoneNumber: userDTO.phoneNumber,
      email: userDTO.email,
      rating: dto.rating,
    );

    return customer;
  }

  Future<CustomerDTO?> getDTO(int customerId) async {
    final newAPIURL = '$_apiUrl/$customerId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, newAPIURL);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode != HttpStatus.ok) {
      log('CustomerServices.getDTO() responseJson.statusCode != HttpStatus.ok ${responseJson.statusCode}');
      return null;
    }

    final responseData = json.decode(responseJson.body);
    final customerDTO = CustomerDTO.fromJson(responseData['result']);

    return customerDTO;
  }

  Future<int> create(CustomerCreateDTO createDTO) async {
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
      log('CustomerServices.create() responseJson.statusCode != HttpStatus.created');
      inspect(responseJson);

      return 0;
    }

    final responseData = json.decode(responseJson.body);

    final createdOrderId = responseData['result']['customerId'] as int;

    return createdOrderId;
  }

  Future<bool> update(int id, CustomerUpdateDTO updateDTO) async {
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
      log('CustomerServices.update() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return false;
    }

    return true;
  }
}
