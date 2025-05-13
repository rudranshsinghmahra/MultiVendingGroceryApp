import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../providers/cart_provider.dart';
import '../providers/location_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/welcome_screen.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String? _location = "";
  String? _address = "";

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      _location = location;
      _address = address;
      print(_address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context);
    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 150,
      automaticallyImplyLeading: true,
      elevation: 0.0,
      floating: true,
      snap: true,
      title: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          EasyLoading.show(status: "Please Wait...");
          try {
            locationData.getMyCurrentPosition().then((value) {
              if (value != null) {
                pushScreen(context, screen: MapScreen());
                EasyLoading.dismiss();
              } else {
                showAlert("Location Permission not Allowed");
                EasyLoading.dismiss();
              }
            });
          } catch (e) {
            print(e.toString());
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _location ?? "Set Delivery Address",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                _address == null ? "Please set Delivery Location" : "$_address",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              pushScreen(context,
                  screen: CartScreen(
                    documentSnapshot:
                    cartProvider.documentSnapshot,
                  ));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 5),
          child: IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              pushScreen(context, screen: ProfileScreen());
            },
          ),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                hintText: "Search",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
