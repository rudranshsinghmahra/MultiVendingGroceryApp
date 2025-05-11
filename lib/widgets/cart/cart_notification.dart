import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../screens/cart_screen.dart';
import '../../services/cart_services.dart';

class CartNotification extends StatefulWidget {
  const CartNotification({super.key});

  @override
  State<CartNotification> createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  CartServices cartServices = CartServices();
  DocumentSnapshot? documentSnapshot;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    cartProvider.getCartTotal();
    cartProvider.getShopName();
    return Visibility(
      visible: cartProvider.distance <= 10
          ? cartProvider.cartQty > 0
              ? true
              : false
          : false,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${cartProvider.cartQty} ${cartProvider.cartQty > 1 ? "Items" : "Item"}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        const Text(
                          "  |  ",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          cartProvider.subTotal.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    if (cartProvider.documentSnapshot != null)
                      Text(
                        "From ${cartProvider.documentSnapshot?['shopName']}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  pushScreen(
                    context,
                    screen: CartScreen(
                        documentSnapshot: cartProvider.documentSnapshot),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      "View Cart",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
