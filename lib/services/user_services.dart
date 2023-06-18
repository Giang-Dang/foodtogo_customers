import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodtogo_customers/models/dto/api_response_dto.dart';
import 'package:foodtogo_customers/models/dto/login_request_dto.dart';
import 'package:foodtogo_customers/models/dto/login_response_dto.dart';
import 'package:foodtogo_customers/models/dto/register_request_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_customers/models/dto/user_dto.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const kTokenKeyName = 'loginToken';
const kUserIdKeyName = 'userId';

class UserServices {
  static bool isAuthorized = false;
  static String jwtToken = "";
  static int? userId = 0;
  static double currentLongitude = 0.0;
  static double currentLatitude = 0.0;

  Future<List<UserDTO>?> getAllDTOs({
    String? searchUserName,
    String? searchRole,
    String? searchEmail,
    String? searchPhoneNumber,
    int? pageSize,
    int? pageNumber,
  }) async {
    final jwtToken = UserServices.jwtToken;
    const apiUrl = 'api/UserAPI';

    final queryParams = <String, String>{};
    if (searchUserName != null) {
      queryParams['searchUserName'] = searchUserName;
    }
    if (searchRole != null) {
      queryParams['searchRole'] = searchRole;
    }
    if (searchEmail != null) {
      queryParams['searchEmail'] = searchEmail;
    }
    if (searchPhoneNumber != null) {
      queryParams['searchPhoneNumber'] = searchPhoneNumber;
    }
    if (pageSize != null && pageNumber != null) {
      queryParams['pageSize'] = pageSize.toString();
      queryParams['pageNumber'] = pageNumber.toString();
    }

    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl, queryParams);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final ordersList = (responseData['result'] as List)
          .map((json) => UserDTO.fromJson(json))
          .toList();

      return ordersList;
    }

    return null;
  }

  Future<UserDTO?> getDTO(int userId) async {
    final apiUrl = 'api/UserAPI/$userId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl, {
      'id': userId.toString(),
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      var userDTO = UserDTO(
        id: responseObject['result']['id'],
        username: responseObject['result']['username'],
        role: responseObject['result']['role'],
        phoneNumber: responseObject['result']['phoneNumber'],
        email: responseObject['result']['email'],
      );

      return userDTO;
    }
    return null;
  }

  Future<bool?> isUsernameExist(String searchUsername) async {
    const apiUrl = 'api/UserAPI/checkusername';

    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl, {
      'searchUserName': searchUsername,
    });

    final responseJson = await http.get(url);

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      return responseData['result'] as bool;
    }

    log('isUsernameExist responseJson.statusCode != HttpStatus.ok');

    return null;
  }

  Future<bool> update(int userId, UserUpdateDTO updateDTO) async {
    final apiUrl = 'api/UserAPI/${userId.toString()}';
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);

    final jsonData = json.encode({
      "id": updateDTO.id,
      "phoneNumber": updateDTO.phoneNumber,
      "email": updateDTO.email,
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

  Future<LoginResponseDTO> login(LoginRequestDTO loginRequestDTO) async {
    const loginAPISubUrl = 'api/UserAPI/login';
    final url = Uri.http(Secrets.kFoodToGoAPILink, loginAPISubUrl);

    final jsonData = json.encode({
      "userName": loginRequestDTO.username,
      "password": loginRequestDTO.password,
      "loginFromApp": loginRequestDTO.loginFromApp,
    });

    final responseJson = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);

    LoginResponseDTO loginResponseDTO;

    if (responseObject['isSuccess'] as bool) {
      loginResponseDTO = LoginResponseDTO(
        isSuccess: responseObject['isSuccess'],
        errorMessage: "",
        user: UserDTO(
          id: responseObject['result']['user']['id'],
          username: responseObject['result']['user']['username'],
          role: responseObject['result']['user']['role'],
          phoneNumber: responseObject['result']['user']['phoneNumber'],
          email: responseObject['result']['user']['email'],
        ),
      );

      saveLoginInfo(responseObject['result']['token'] as String,
          responseObject['result']['user']['id'] as int);
      //set static values
      isAuthorized = true;
      jwtToken = responseObject['result']['token'] as String;
      userId = responseObject['result']['user']['id'] as int;
    } else {
      loginResponseDTO = LoginResponseDTO(
        isSuccess: responseObject['isSuccess'],
        errorMessage: responseObject['errorMessages'][0],
      );
    }
    return loginResponseDTO;
  }

  Future<void> checkLocalLoginAuthorized() async {
    jwtToken = await getLoginToken() ?? "";
    final queryUserId = await getStoredUserId();
    userId = int.tryParse(queryUserId ?? "");
    // print('jwtToken $jwtToken');
    // print('strUserId $strUserId');
    if (jwtToken == "" || userId == null || userId == 0) {
      isAuthorized = false;
      jwtToken = "";
      userId = null;
      return;
    }

    final merchantAPIByUserIdLink = 'api/MerchantAPI/byuser/$userId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, merchantAPIByUserIdLink);

    final responseJson = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      isAuthorized = true;
      return;
    }

    isAuthorized = false;
    jwtToken = "";
    userId = null;
    return;
  }

  Future<APIResponseDTO> register(RegisterRequestDTO registerRequestDTO) async {
    const registerAPISubUrl = 'api/UserAPI/register';
    final url = Uri.http(Secrets.kFoodToGoAPILink, registerAPISubUrl);

    final jsonData = json.encode({
      "userName": registerRequestDTO.username,
      "password": registerRequestDTO.password,
      "phoneNumber": registerRequestDTO.phoneNumber,
      "email": registerRequestDTO.email,
    });

    final responseJson = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);

    if (!responseObject['isSuccess']) {
      return APIResponseDTO(
        statusCode: responseObject['statusCode'],
        isSuccess: responseObject['isSuccess'],
        errorMessages: [],
        result: null,
      );
    }
    
    return APIResponseDTO(
      statusCode: responseObject['statusCode'],
      isSuccess: responseObject['isSuccess'],
      errorMessages: [],
      result: responseObject['result']['id'] as int,
    );
  }

  FlutterSecureStorage getSecureStorage() {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    return storage;
  }

  Future<void> saveLoginInfo(String token, int userId) async {
    final storage = getSecureStorage();
    await storage.delete(key: kTokenKeyName);
    await storage.delete(key: kUserIdKeyName);
    await storage.write(key: kTokenKeyName, value: token);
    await storage.write(key: kUserIdKeyName, value: userId.toString());
  }

  Future<void> deleteStoredLoginInfo() async {
    final storage = getSecureStorage();
    await storage.delete(key: kTokenKeyName);
    await storage.delete(key: kUserIdKeyName);
  }

  Future<String?> getLoginToken() async {
    final storage = getSecureStorage();
    return await storage.read(key: kTokenKeyName);
  }

  Future<String?> getStoredUserId() async {
    final storage = getSecureStorage();
    return await storage.read(key: kUserIdKeyName);
  }

  bool isValidUsername(String? username) {
    RegExp validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
    if (username == null) {
      return false;
    }
    return username.length >= 4 &&
        username.length <= 30 &&
        validCharacters.hasMatch(username);
  }

  bool isValidEmail(String? email) {
    RegExp validRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+');
    if (email == null) {
      return false;
    }
    return validRegex.hasMatch(email);
  }

  bool isValidPhoneNumber(String? phoneNumber) {
    // Regular expression pattern to match valid phone numbers
    String pattern =
        r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-6]|9[0-46-9])[0-9]{7}$|^(0|\+84)(2[0-9]{1}|[3-9]{1})[0-9]{8}$';
    RegExp regExp = RegExp(pattern);

    if (phoneNumber == null) {
      return false;
    }
    // Check if the phone number matches the pattern
    if (regExp.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getUserLocation() async {
    final locationServices = LocationServices();

    double locationAccuracy = 200.0;
    Position locationData = await locationServices.determinePosition();

    int attempts = 0;
    while (locationAccuracy > 50.0 && attempts < 10) {
      locationData = await locationServices.determinePosition();
      log(locationData.accuracy.toString());
      locationAccuracy = math.min(locationAccuracy, locationData.accuracy);
      attempts++;
    }

    currentLatitude = locationData.latitude;
    currentLongitude = locationData.longitude;
  }

  bool isValidVietnameseName(String? name) {
    if (name == null) {
      return false;
    }

    final RegExp nameRegExp = RegExp(
      r'^[a-zA-Z\u00C0-\u1EF9]+(?:\s[a-zA-Z\u00C0-\u1EF9]+)*$',
    );
    return nameRegExp.hasMatch(name);
  }
}
