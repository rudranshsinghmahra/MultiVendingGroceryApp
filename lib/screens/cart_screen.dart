import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/payment_home.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../providers/authentication_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/coupons_provider.dart';
import '../providers/location_provider.dart';
import '../providers/orders_provider.dart';
import '../services/cart_services.dart';
import '../services/order_services.dart';
import '../services/services_user.dart';
import '../services/store_services.dart';
import '../widgets/billing_details.dart';
import '../widgets/cart/cart_list.dart';
import '../widgets/cart/coupon_widget.dart';
import '../widgets/custom_toggle_button.dart';
import 'map_screen.dart';

class CartScreen extends StatefulWidget {
  static const String id = "cart-screen";

  const CartScreen({super.key, this.documentSnapshot});

  final DocumentSnapshot? documentSnapshot;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final StoreServices _store = StoreServices();
  final UserServices _userServices = UserServices();
  final OrderService _orderService = OrderService();
  User? user = FirebaseAuth.instance.currentUser;
  final CartServices _cartServices = CartServices();

  DocumentSnapshot? dSnapshot;
  var textStyle = const TextStyle(color: Colors.grey);
  double discount = 0.0;
  var deliveryFee = 50.0;
  bool _loading = false;
  bool checkingUser = false;

  String? location = "";
  String? address = "";

  @override
  void initState() {
    getPreferences();
    _store.getShopDetails(widget.documentSnapshot?['sellerUid']).then((value) {
      setState(() {
        dSnapshot = value;
      });
    });
    super.initState();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      this.location = location;
      this.address = address;
    });
  }

  _saveOrder(CartProvider cartProvider, payable, CouponProvider coupon,
      OrderProvider orderProvider) {
    _orderService.saveOrder({
      'products': cartProvider.cartList,
      'userId': user?.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'discount': discount.toStringAsFixed(0),
      'cod': cartProvider.cod,
      'discountCode': coupon.documentSnapshot == null
          ? null
          : coupon.documentSnapshot?['title'],
      'seller': {
        'shopName': widget.documentSnapshot?['shopName'],
        'sellerId': widget.documentSnapshot?['sellerUid'],
      },
      'timestamp': DateTime.now().toString(),
      'orderStatus': 'Ordered',
      'deliveryBoy': {
        'name': '',
        'phone': '',
        'location': const GeoPoint(0, 0),
        'email': '',
        'image': '',
      }
    }).then((value) {
      orderProvider.success = false;
      _cartServices.deleteCart().then((value) {
        _cartServices.checkData().then((value) {
          EasyLoading.showSuccess(
              "Order successfully placed will be accepted or reject soon");
          Navigator.pop(context);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);
    var couponProvider = Provider.of<CouponProvider>(context);
    var payable = cartProvider.subTotal + deliveryFee - discount;
    final locationData = Provider.of<LocationProvider>(context);
    var userDetails = Provider.of<AuthenticationProvider>(context);
    userDetails.getUserDetails().then((value) {
      double subTotal = cartProvider.subTotal;
      double discountRate = couponProvider.discountRate / 100;
      if (mounted) {
        setState(() {
          discount = subTotal * discountRate;
        });
      }
    });
    final orderProvider = Provider.of<OrderProvider>(context);
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          bottomNavigationBar: userDetails.documentSnapshot == null
              ? Container()
              : Container(
                  height: 160,
                  color: Colors.deepPurple.shade300,
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Deliver to this Address : ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _loading = false;
                                      });
                                      locationData
                                          .getMyCurrentPosition()
                                          .then((value) {
                                        if (value != null) {
                                          setState(() {
                                            _loading = false;
                                          });
                                          pushScreen(context,
                                              screen: MapScreen());
                                        } else {
                                          showAlert(
                                              "Location Permission not Allowed");
                                        }
                                      });
                                    },
                                    child: _loading
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            "Change",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 15),
                                          ),
                                  )
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  userDetails.documentSnapshot?['firstName'] !=
                                          null
                                      ? "${userDetails.documentSnapshot?['firstName']} ${userDetails.documentSnapshot?['lastName']} : $location, $address"
                                      : "$location, $address",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Rs ${payable.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Including Taxes",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  EasyLoading.show(status: "Please Wait...");
                                  _userServices
                                      .getUserDataById(user!.uid)
                                      .then((value) {
                                    if (value['firstName'] == null) {
                                      EasyLoading.dismiss();
                                      pushScreen(context,
                                          screen: ProfileScreen());
                                    } else {
                                      EasyLoading.dismiss();
                                      // EasyLoading.show(status: "Please Wait....");
                                      //TODO: PAYMENT GATEWAY INTEGRATION
                                      if (cartProvider.cod == false) {
                                        //Pay Online
                                        orderProvider.totalAmountPayable(
                                            payable,
                                            widget
                                                .documentSnapshot?['shopName'],
                                            userDetails
                                                .documentSnapshot?['email']);
                                        Navigator.pushNamed(
                                                context, PaymentHome.id)
                                            .whenComplete(() {
                                          print(orderProvider.success);
                                          if (orderProvider.success == true) {
                                            _saveOrder(cartProvider, payable,
                                                couponProvider, orderProvider);
                                          }
                                        });
                                      } else {
                                        // Cash On Delivery
                                        _saveOrder(cartProvider, payable,
                                            couponProvider, orderProvider);
                                      }
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.redAccent)),
                                child: checkingUser
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "CHECKOUT",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBozIsSxRolled) {
              return [
                SliverAppBar(
                  iconTheme: const IconThemeData.fallback(),
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.documentSnapshot?['shopName'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Row(
                        children: [
                          Text(
                            "${cartProvider.cartQty} ${cartProvider.cartQty > 1 ? "Items" : "Item"}",
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            "To Pay : Rs ${payable.toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ];
            },
            body: dSnapshot == null
                ? const Center(child: CircularProgressIndicator())
                : cartProvider.cartQty > 0
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 56),
                        child: Column(
                          children: [
                            Column(children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ListTile(
                                leading: SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: Image.network(
                                      dSnapshot?['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(dSnapshot?['shopName']),
                                subtitle: Text(
                                  dSnapshot?['address'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                              const CustomToggleButton(),
                              Divider(
                                color: Colors.grey[300],
                              )
                            ]),
                            CartList(
                              documentSnapshot: widget.documentSnapshot,
                            ),
                            CouponWidget(
                              couponVendor: dSnapshot?['uid'],
                            ),
                            BillingDetailsWidget(
                              subTotal: cartProvider.subTotal,
                              discount: discount,
                              deliveryFee: deliveryFee,
                              payable: payable,
                              savings: cartProvider.savings,
                              textStyle: textStyle,
                            )
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Cart is Empty , Please add some products",
                          textAlign: TextAlign.center,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
