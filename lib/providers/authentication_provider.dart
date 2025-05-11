import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/services_user.dart';
import 'location_provider.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  String verificationId = "";
  bool isLoading = false;
  final UserServices _userServices = UserServices();
  LocationProvider locationData = LocationProvider();
  DocumentSnapshot? documentSnapshot;
  late String currentScreen;
  double? latitude;
  double? longitude;
  String? address;
  String? location;

  void createUser({
    String? id,
    String? number,
  }) {
    _userServices.createUser({
      'firstName': "First",
      'lastName': "Last",
      'email': "firstlast@gmail.com",
      'id': id,
      'number': number,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'location': location,
    });
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser({
    String? id,
    String? number,
  }) async {
    try {
      _userServices.updateUserData({
        'id': id,
        'number': number,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'location': location,
      });
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error $e");
      return false;
    }
  }

  getUserDetails() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get();
    documentSnapshot = result;
    notifyListeners();
      return result;
  }
}
