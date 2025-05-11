import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/cart_services.dart';
import 'cart_card.dart';

class CartList extends StatefulWidget {
  const CartList({super.key, this.documentSnapshot});
  final DocumentSnapshot? documentSnapshot;

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final CartServices _cartServices = CartServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _cartServices.cart
          .doc(_cartServices.user?.uid)
          .collection('products')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            },
          );
        }

        var cartItems = snapshot.data!.docs;

        if (cartItems.isEmpty) {
          return const Center(child: Text("Your cart is empty."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            return CartCard(documentSnapshot: cartItems[index]);
          },
        );
      },
    );
  }
}