import 'dart:convert';

import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class LocationServices {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  String getlocationImageUrl(double lat, double lng) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lng&key=${Secrets.kMapsAPIKey}';
  }

  Future<String> getAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Secrets.kMapsAPIKey}');

    final response = await http.get(url);
    final resData = json.decode(response.body);
    return resData['results'][0]['formatted_address'];
  }

  Future<LatLng?> getCoordinates(String address) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': address,
        'key': Secrets.kMapsAPIKey,
      },
    );
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (data['results'].length == 0) {
      return null;
    }
    final lat = data['results'][0]['geometry']['location']['lat'];
    final lng = data['results'][0]['geometry']['location']['lng'];
    return LatLng(lat, lng);
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lng2 - lng1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }
}
