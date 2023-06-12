import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;

class MerchantRatingServices {
  static const _apiUrl = 'api/MerchantRatingAPI';
  Future<double?> getAvgRating(int merchantId) async {
    const newApiUrl = '$_apiUrl/avgrating';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.kFoodToGoAPILink, newApiUrl, {
      'toMerchantId': merchantId.toString(),
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      return responseObject['result'].toDouble();
    }
    return null;
  }
}
