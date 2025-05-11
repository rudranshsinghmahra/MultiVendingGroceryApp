import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';
import 'package:multi_vending_grocery_app/services/favouriteServices.dart';

class FavouriteProductCard extends StatefulWidget {
  const FavouriteProductCard(
      {super.key, required this.documentSnapshot, required this.currentDocId});

  final Map<String, dynamic> documentSnapshot;
  final String currentDocId;

  @override
  State<FavouriteProductCard> createState() => _FavouriteProductCardState();
}

class _FavouriteProductCardState extends State<FavouriteProductCard> {
  CartServices cartServices = CartServices();
  FavouriteServices favouriteServices = FavouriteServices();
  User? user = FirebaseAuth.instance.currentUser;
  int qty = 1;
  String? docId;
  bool exist = false;

  Stream<QuerySnapshot> getFavProductStream() {
    return FirebaseFirestore.instance
        .collection('cart')
        .doc(user?.uid)
        .collection('products')
        .where('productId',
            isEqualTo: widget.documentSnapshot['product']['productId'])
        .snapshots();
  }

  showDialogBox(shopName) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Replace Cart Item?"),
          content: Text(
              "Your cart contains item from $shopName. Do you want to discard the selection and add items from ${widget.documentSnapshot['product']['seller']['shopName']}"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "No",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  cartServices.deleteCart().then((value) {
                    cartServices
                        .addToCart(widget.documentSnapshot['product'])
                        .then((value) {
                      if (mounted) {
                        setState(() {
                          exist = true;
                          Navigator.pop(context);
                        });
                      }
                    });
                  });
                },
                child: const Text("Yes",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getFavProductStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          bool exist = docs.isNotEmpty;
          this.exist = exist;

          // If the product exists in the favorites, extract additional details
          if (exist) {
            final productDoc = docs.first;
            qty = productDoc['qty'];
            docId = productDoc.id;
          }

          return SizedBox(
            height: 150,
            width: double.infinity,
            child: Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      height: double.infinity,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: NetworkImage(
                            "${widget.documentSnapshot['product']['productImage']}",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.documentSnapshot['product']
                                    ['productName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  favouriteServices.removeProductFromFavorites(
                                      widget.currentDocId);
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                          const Text(
                            "Medium, Light Blue",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "Rs ${widget.documentSnapshot['product']['price']}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: exist
                                ? null
                                : () {
                                    cartServices.checkSeller().then((shopName) {
                                      print(shopName);
                                      print(widget.documentSnapshot['product']
                                          ['seller']['shopName']);
                                      if (shopName ==
                                          widget.documentSnapshot['product']
                                              ['seller']['shopName']) {
                                        cartServices
                                            .addToCart(widget
                                                .documentSnapshot['product'])
                                            .then((_) {
                                          EasyLoading.showSuccess(
                                              "Added to Cart");
                                        });
                                      } else if (shopName !=
                                              widget.documentSnapshot['product']
                                                  ['seller']['shopName'] &&
                                          shopName != "") {
                                        EasyLoading.dismiss();
                                        showDialogBox(shopName);
                                      } else {
                                        cartServices
                                            .addToCart(widget
                                                .documentSnapshot['product'])
                                            .then((_) {
                                          EasyLoading.showSuccess(
                                              "Added to Cart");
                                        });
                                      }
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: exist ? Colors.grey : Colors.red,
                            ),
                            child: Text(
                              exist ? "Already in Cart" : "Add to Cart",
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text("No data found"));
        }
      },
    );
  }
}
