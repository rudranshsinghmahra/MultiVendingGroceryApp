import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/services/favouriteServices.dart';
import 'package:provider/provider.dart';

import '../services/cart_services.dart';
import '../widgets/favourite_product_card.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  FavouriteServices favouriteServices = FavouriteServices();
  User? user = FirebaseAuth.instance.currentUser;
  final CartServices cartServices = CartServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Favourite",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.search,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: StreamBuilder(
            stream: favouriteServices.favourites
                .where("customerId", isEqualTo: user?.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data?.size == 0) {
                return const Center(
                  child: Text("No product added as Favourite"),
                );
              }
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      5,
                ),
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return FavouriteProductCard(
                      documentSnapshot: data,
                      currentDocId: document.id,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
