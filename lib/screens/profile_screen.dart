import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/screens/cart_screen.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/credit_card_list.dart';
import 'package:multi_vending_grocery_app/screens/profile_update_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/location_provider.dart';
import 'map_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String id = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthenticationProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context);
    userDetails.getUserDetails();
    var location = Provider.of<LocationProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Grocery Store",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: userDetails.documentSnapshot == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              color: Colors.deepPurple.shade300,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: Text(
                                            userDetails.documentSnapshot != null
                                                ? "${userDetails.documentSnapshot?['firstName'].toString().substring(0, 1)}"
                                                : "1",
                                            style: const TextStyle(
                                                fontSize: 50,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          height: 70,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                userDetails.documentSnapshot !=
                                                        null
                                                    ? "${userDetails.documentSnapshot?['firstName']} ${userDetails.documentSnapshot?['lastName']}"
                                                    : "Update Your Name",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                              if (userDetails.documentSnapshot?[
                                                      'email'] !=
                                                  null)
                                                Text(
                                                  "${userDetails.documentSnapshot?['email']}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              Text(
                                                user!.phoneNumber.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (userDetails.documentSnapshot != null)
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.location_on,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          title: userDetails.documentSnapshot?[
                                                      'location'] ==
                                                  null
                                              ? const Text("Location not Set")
                                              : Text(
                                                  userDetails.documentSnapshot?[
                                                      'location']),
                                          subtitle: userDetails
                                                          .documentSnapshot?[
                                                      'address'] ==
                                                  null
                                              ? const Text(
                                                  "Complete Address not Set")
                                              : Text(
                                                  userDetails.documentSnapshot?[
                                                      'address'],
                                                  maxLines: 2,
                                                ),
                                          trailing: OutlinedButton(
                                            child: Text("Change"),
                                            onPressed: () {
                                              EasyLoading.show(
                                                  status: "Please Wait...");
                                              location
                                                  .getMyCurrentPosition()
                                                  .then((value) {
                                                if (value != null) {
                                                  EasyLoading.dismiss();
                                                  pushScreen(context,
                                                      screen: MapScreen());
                                                } else {
                                                  EasyLoading.dismiss();
                                                  print(
                                                      "Permission Not Allowed");
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                right: 10.0,
                                top: 10.0,
                                child: IconButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    pushScreen(context,
                                        screen: UpdateProfile());
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                ))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            onTap: () {
                              pushScreen(context,
                                  screen: CartScreen(
                                    documentSnapshot:
                                        cartProvider.documentSnapshot,
                                  ));
                            },
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.shopping_cart),
                            title: Text("My Cart"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            onTap: () {
                              pushScreen(context, screen: MyOrdersScreen());
                            },
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history),
                            title: Text("My Orders"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            onTap: () {
                              pushScreen(context, screen: CreditCardList());
                            },
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.credit_card),
                            title: const Text("Manage Cards"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.comment_outlined),
                            title: Text("My Ratings And Reviews"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.notifications_none),
                            title: Text("Notifications"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.power_settings_new),
                            title: Text("Logout"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ));
  }
}
