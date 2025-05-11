import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteServices {
  CollectionReference favourites =
      FirebaseFirestore.instance.collection("favourites");

  Future removeProductFromFavorites(String docId) async {
    await favourites.doc(docId).delete();
  }
}
