import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_customers/models/order_success_rate.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OrderSuccessRateServices {
  static const _apiUrl = 'api/OrderAPI/successrate';
  Future<OrderSuccessRate?> getSuccessRate(int userId, String asType) async {
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.kFoodToGoAPILink, _apiUrl,
        {'userId': userId.toString(), 'asType': asType});

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      return OrderSuccessRate(
        successOrderCount: responseData['result']['successOrderCount'],
        cancelledOrderCount: responseData['result']['cancelledOrderCount'],
      );
    }
    return null;
  }
}
