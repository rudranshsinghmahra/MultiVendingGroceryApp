import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../services/product_services.dart';

class ProductFilterWidget extends StatelessWidget {
  ProductFilterWidget({super.key});

  final ProductServices _services = ProductServices();

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<StoreProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: _services.category.doc(store.selectedProductCategory).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Went Wrong");
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final subCategories = data['subCategory'] as List<dynamic>;

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 10),
          children: [
            ActionChip(
              elevation: 4,
              label: Text("All ${store.selectedProductCategory}"),
              onPressed: () {
                store.selectedCategorySub(null);
              },
              backgroundColor: Colors.white,
            ),
            ...subCategories.map((sub) {
              final name = sub['name'];
              return Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ActionChip(
                  elevation: 4,
                  label: Text(name),
                  onPressed: () {
                    store.selectedCategorySub(name);
                  },
                  backgroundColor: Colors.white,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
