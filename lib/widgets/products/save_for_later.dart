import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveForLater extends StatefulWidget {
  const SaveForLater({super.key, this.documentSnapshot});
  final DocumentSnapshot? documentSnapshot;

  @override
  State<SaveForLater> createState() => _SaveForLaterState();
}

class _SaveForLaterState extends State<SaveForLater> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavourite();
  }

  void checkIfFavourite() {
    FirebaseFirestore.instance
        .collection('favourites')
        .where('product.productId', isEqualTo: widget.documentSnapshot?['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['product']['productId'] == widget.documentSnapshot?['productId']) {
          setState(() {
            isFavourite = true;
          });
        }
      }
    });
  }

  Future<void> saveForLater() async {
    CollectionReference favourites = FirebaseFirestore.instance.collection('favourites');
    User? user = FirebaseAuth.instance.currentUser;

    await favourites.add({
      "product": widget.documentSnapshot?.data(),
      "customerId": user?.uid
    });
    setState(() {
      isFavourite = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isFavourite) {
          EasyLoading.show(status: "Saving").then((_) {
            saveForLater().then((value) {
              EasyLoading.showSuccess("Added as Favourite");
            });
          });
        }else{
          EasyLoading.showInfo("Already marked as Favourite",duration: Duration(seconds: 2));
        }
      },
      child: Container(
        height: 56,
        color: isFavourite ? Colors.grey.shade500 : Colors.grey[800],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bookmark,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  isFavourite ? "Already marked as \nFavourite" : "Mark as Favourite",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
