import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class LocationProvider extends ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;
  bool permissionAllowed = true;
  geocoding.Placemark? selectedAddress;
  bool isLoading = false;

  Future<Position?> getMyCurrentPosition() async {
    Position? position;
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permissionAllowed = false;
      showAlert("Location Permission is Denied. Allow to use app");
    } else if (permission == LocationPermission.deniedForever) {
      permissionAllowed = false;
      showAlert("Location Permission is Denied Forever. Enable in Settings");
    } else {
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      permissionAllowed = true;
      notifyListeners();
      latitude = position.latitude;
      longitude = position.longitude;

      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      selectedAddress = placemarks.first;
    }
    return position;
  }

  void onCameraMove(CameraPosition cameraPosition) async {
    latitude = cameraPosition.target.latitude;
    longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(latitude, longitude);
    selectedAddress = placemarks.first;
    notifyListeners();
    print("${selectedAddress?.name} : ${selectedAddress?.street}");
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', latitude);
    prefs.setDouble('longitude', longitude);
    prefs.setString('address', selectedAddress!.street ?? '');
    prefs.setString('location', selectedAddress!.name ?? '');
  }
}
