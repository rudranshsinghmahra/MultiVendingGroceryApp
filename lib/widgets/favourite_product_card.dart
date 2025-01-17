import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isLoading = true;
  int qty = 1;
  bool exist = false;
  String? docId;

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await cartServices.cart.doc(user?.uid).collection('products').get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user?.uid)
        .collection('products')
        .where('productId',
            isEqualTo: widget.documentSnapshot['product']['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['productId'] ==
            widget.documentSnapshot['product']['productId']) {
          if (mounted) {
            setState(() {
              exist = true;
              qty = doc['qty'];
              docId = doc.id;
            });
          }
        }
      }
    });

    return SizedBox(
      height: 125,
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
                          widget.documentSnapshot['product']['productName'],
                          style: TextStyle(
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
                    Text(
                      "Medium, Light Blue",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Rs ${widget.documentSnapshot['product']['price']}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: isLoading
                              ? SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor),
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    exist
                                        ? null
                                        : cartServices
                                            .addToCart(widget
                                                .documentSnapshot['product'])
                                            .then((_) {
                                            setState(() {
                                              exist = true;
                                            });
                                            EasyLoading.showSuccess(
                                                "Added to Cart");
                                          });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        exist ? Colors.grey : Colors.red,
                                  ),
                                  child: exist
                                      ? Text(
                                          "Already in Cart",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : Text(
                                          "Add to Cart",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
