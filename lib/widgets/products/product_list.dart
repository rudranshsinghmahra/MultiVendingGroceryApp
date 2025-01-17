import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';

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
          .where('categoryName.subCategory', isEqualTo: storeProvider.selectedSubCategory)
          .where('seller.sellerUid',
              isEqualTo: storeProvider.storeDetails?['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Went Wrong");
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
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
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4)),
                height: 56,
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
