import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:flutter_config/flutter_config.dart';

final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');

class LocationNotifier extends StateNotifier {
  LocationNotifier() : super('');

  Future<LocationData> getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('無法取得當前位置。');
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('無法取得當前位置。');
        }
      }

      locationData = await location.getLocation();
    } catch (err) {
      throw Exception('無法取得當前位置。');
    }

    return locationData;
  }

  Future<String> getAddress(double lat, double long) async {
    final res = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        "latlng": "$lat,$long",
        "key": googleApiKey,
        "language": "zh-TW",
      }),
    );
    return json.decode(res.body)['results'][0]['formatted_address'];
  }
}

final locationProvider = StateNotifierProvider(
  (ref) {
    return LocationNotifier();
  },
);
