import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  String collection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Function to Create User Data
  Future<void> createUser(Map<String, dynamic> map) async {
    String id = map['id'];
    await _firestore.collection(collection).doc(id).set(map);
  }

  //Function to Update User Data
  Future<void> updateUserData(Map<String, dynamic> map) async {
    String id = map['id'];
    await _firestore.collection(collection).doc(id).update(map);
  }

  //Function to Getting User Data
  Future<DocumentSnapshot> getUserDataById(String id) async {
    var result = await _firestore.collection(collection).doc(id).get();
    return result;
  }
}
