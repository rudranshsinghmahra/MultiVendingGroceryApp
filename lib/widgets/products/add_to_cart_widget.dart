import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../services/cart_services.dart';
import '../cart/counter_widget.dart';

class AddToCardWidget extends StatefulWidget {
  const AddToCardWidget({super.key, this.documentSnapshot});

  final DocumentSnapshot? documentSnapshot;

  @override
  State<AddToCardWidget> createState() => _AddToCardWidgetState();
}

class _AddToCardWidgetState extends State<AddToCardWidget> {
  final CartServices _cartServices = CartServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  bool exists = false;
  int _qty = 1;
  String? _docId;

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _cartServices.cart.doc(user?.uid).collection('products').get();
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
    //If Product exist in cart , we need to get qty details
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user?.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.documentSnapshot?['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['productId'] == widget.documentSnapshot?['productId']) {
          if(mounted){
            setState(() {
              exists = true;
              _qty = doc['qty'];
              _docId = doc.id;
            });
          }
        }
      }
    });

    return isLoading
        ? SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : exists
            ? CounterWidget(
                documentSnapshot: widget.documentSnapshot,
                qty: _qty,
                docId: _docId.toString(),
              )
            : InkWell(
                onTap: () {
                  EasyLoading.show(status: "Adding Product To Cart");
                  _cartServices
                      .addToCart(widget.documentSnapshot)
                      .then((value) {
                    setState(() {
                      exists = true;
                    });
                    EasyLoading.showSuccess("Added to Cart");
                  });
                },
                child: Container(
                  height: 56,
                  color: Colors.red[400],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            CupertinoIcons.shopping_cart,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Add to Basket",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
