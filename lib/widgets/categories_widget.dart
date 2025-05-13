import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';  // <-- Add shimmer

import '../providers/store_provider.dart';
import '../services/product_services.dart';
import '../screens/product_list_screen.dart';

class VendorCategories extends StatefulWidget {
  const VendorCategories({super.key});

  @override
  State<VendorCategories> createState() => _VendorCategoriesState();
}

class _VendorCategoriesState extends State<VendorCategories> {
  final ProductServices productServices = ProductServices();
  List<String> categoriesList = [];

  // Use a Future to load categories efficiently
  Future<void> loadCategories() async {
    var store = Provider.of<StoreProvider>(context, listen: false);
    // Fetch unique categories once using a distinct query to avoid fetching all products
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('seller.sellerUid', isEqualTo: store.storeDetails?['uid'])
        .get();

    Set<String> categorySet = {}; // Set to ensure unique categories

    for (var doc in querySnapshot.docs) {
      categorySet.add(doc['categoryName']['mainCategory']);
    }

    if(mounted){
      setState(() {
        categoriesList = categorySet.toList(); // Converting set to list
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories(); // Load categories on widget initialization
  }

  @override
  Widget build(BuildContext context) {
    var services = Provider.of<StoreProvider>(context);

    return FutureBuilder(
      future: productServices.category.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something Went Wrong"),
          );
        }

        if (categoriesList.isEmpty) {
          // Show shimmer effect while categories are loading
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/city.png')),
                      ),
                      child: const Text(
                        "Shop by Category",
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
                SizedBox(
                  height: 10,
                ),
                // Shimmer effect for category items
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: List.generate(2, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No Categories Available"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/city.png')),
                    ),
                    child: const Text(
                      "Shop by Category",
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
              SizedBox(
                height: 10,
              ),
              Wrap(
                direction: Axis.horizontal,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return categoriesList.contains(document['name'])
                      ? Padding(
                    padding: const EdgeInsets.all(3.5),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      width: 120,
                      height: 180,
                      child: InkWell(
                        onTap: () {
                          services.selectedCategory(document['name']);
                          services.selectedCategorySub(null);
                          pushScreen(context,
                              screen: ProductListScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.grey, width: 1.5)),
                          child: Column(
                            children: [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  height: 120,
                                  child:
                                  Image.network(document['images']),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8),
                                child: Text(
                                  document['name'],
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(); // Empty widget for no match
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
