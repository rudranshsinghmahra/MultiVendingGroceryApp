import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FavouriteServices extends ChangeNotifier {
  CollectionReference favourites =
      FirebaseFirestore.instance.collection("favourites");

  Future removeProductFromFavorites(String docId) async {
    await favourites.doc(docId).delete();
  }
}
