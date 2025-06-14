import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/cart_services.dart';
import '../products/add_to_cart_widget.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget(
      {super.key, this.documentSnapshot, required this.qty, required this.docId});
  final DocumentSnapshot? documentSnapshot;
  final int qty;
  final String docId;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  CartServices cartServices = CartServices();
  int _qty = 1;
  bool _updating = false;
  bool _exists = true;

  @override
  Widget build(BuildContext context) {
    setState(() {
      _qty = widget.qty;
    });
    return _exists
        ? Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            height: 56,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FittedBox(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                          });
                          if (_qty == 1) {
                            cartServices
                                .removeFromCart(widget.docId)
                                .then((value) {
                              setState(() {
                                _updating = false;
                                _exists = false;
                              });
                              cartServices.checkData();
                            });
                          }
                          if (_qty > 1) {
                            setState(() {
                              _qty--;
                            });
                            var total =
                                _qty * widget.documentSnapshot?['price'];
                            cartServices
                                .updateCartQty(widget.docId, _qty, total)
                                .then((value) {
                              setState(() {
                                _updating = false;
                              });
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _qty == 1 ? Icons.delete_outlined : Icons.remove,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 8, bottom: 8),
                        child: _updating
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                              )
                            : Text(
                                _qty.toString(),
                                style: const TextStyle(color: Colors.red),
                              ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                            _qty++;
                          });
                          var total = _qty * widget.documentSnapshot?['price'];
                          cartServices
                              .updateCartQty(widget.docId, _qty, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.add,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : AddToCardWidget(
            documentSnapshot: widget.documentSnapshot,
          );
  }
}
