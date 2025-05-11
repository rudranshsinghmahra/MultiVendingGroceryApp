import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // <-- Add shimmer

import '../../providers/store_provider.dart';
import '../../services/product_services.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProductServices services = ProductServices();
    var storeProvider = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: services.products
          .where('published', isEqualTo: true)
          .where('categoryName.mainCategory',
          isEqualTo: storeProvider.selectedProductCategory)
          .where('categoryName.subCategory',
          isEqualTo: storeProvider.selectedSubCategory)
          .where('seller.sellerUid',
          isEqualTo: storeProvider.storeDetails?['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Went Wrong");
        }

        if (!snapshot.hasData) {
          // Show shimmer placeholders
          return Column(
            children: [
              // Shimmer for the "Items count" bar
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 56,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Shimmer list for ProductCard placeholders
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return Column(
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 56,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "${snapshot.data.docs.length} Items",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children:
              snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
                return ProductCard(documentSnapshot: document);
              }).toList(),
            )
          ],
        );
      },
    );
  }
}
