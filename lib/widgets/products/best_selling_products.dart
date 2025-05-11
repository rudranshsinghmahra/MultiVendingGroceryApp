import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';  // <-- Add shimmer

import '../../providers/store_provider.dart';
import '../../services/product_services.dart';
import '../../widgets/products/product_card_widget.dart';

class BestSellingProduct extends StatelessWidget {
  const BestSellingProduct({super.key});

  @override
  Widget build(BuildContext context) {
    ProductServices services = ProductServices();
    var storeProvider = Provider.of<StoreProvider>(context);

    Future<QuerySnapshot> getBestSellingProducts() async {
      return services.products
          .where('published', isEqualTo: true)
          .where('collection', isEqualTo: "Best Selling")
          .where('seller.sellerUid', isEqualTo: storeProvider.storeDetails?['uid'])
          .get();
    }

    return FutureBuilder<QuerySnapshot>(
      future: getBestSellingProducts(), // Use the method to get products
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something Went Wrong"));
        }

        if (!snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              children: [
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
                      height: 56,
                      child: const Center(
                        child: Text(
                          "Best Selling Products",
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
                SizedBox(height: 10),

                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        var products = snapshot.data!.docs;

        return Column(
          children: [
            if (products.isNotEmpty)
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
                    height: 56,
                    child: const Center(
                      child: Text(
                        "Best Selling Products",
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

            ListView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ProductCard(documentSnapshot: products[index]);
              },
            ),
          ],
        );
      },
    );
  }
}
