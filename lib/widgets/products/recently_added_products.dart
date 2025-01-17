import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../services/product_services.dart';

class RecentlyAddedProducts extends StatelessWidget {
  const RecentlyAddedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    ProductServices services = ProductServices();
    var storeProvider = Provider.of<StoreProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context);

    return FutureBuilder<QuerySnapshot>(
        future: services.products
            .where('published', isEqualTo: true)
            .where('collection', isEqualTo: "Recently Added")
            .where('seller.sellerUid',
                isEqualTo: storeProvider.storeDetails?['uid'])
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text("Something Went Wrong");
          }
          if (!snapshot.hasData) {
            return Container();
          }
          return Column(
            children: [
              if (snapshot.data.docs.length > 0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(4)),
                      height: 95,
                      child: Center(
                        child: Text(
                          "Recently Added Products",
                          style: TextStyle(
                              shadows: [
                                Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                    color: Colors.black)
                              ],
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: cartProvider.cartQty > 0
                    ? EdgeInsets.only(bottom: 100.0)
                    : EdgeInsets.only(bottom: 50.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data.docs
                      .map<Widget>((DocumentSnapshot document) {
                    return ProductCard(documentSnapshot: document);
                  }).toList(),
                ),
              )
            ],
          );
        });
  }
}
