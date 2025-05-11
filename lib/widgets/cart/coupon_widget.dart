import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../providers/coupons_provider.dart';

class CouponWidget extends StatefulWidget {
  const CouponWidget({super.key, required this.couponVendor});
  final String couponVendor;

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  Color _color = Colors.grey;
  bool _enable = false;
  bool _isVisible = false;
  TextEditingController couponController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var coupon = Provider.of<CouponProvider>(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10,top: 10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TextField(
                        controller: couponController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Voucher Code",
                          hintStyle: TextStyle(
                            fontSize: 12
                          ),
                          filled: true,
                          fillColor: Colors.grey[300],
                        ),
                        onChanged: (String value) {
                          if (value.length < 3) {
                            setState(() {
                              _color = Colors.grey;
                              _enable = false;
                            });
                            if (value.isNotEmpty) {
                              _color = Theme.of(context).primaryColor;
                              _enable = true;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: _enable ? false : true,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(_color),
                        ),
                        onPressed: () {
                          EasyLoading.show(status: "Validating Coupon...");
                          coupon
                              .getCouponDetails(
                                  couponController.text, widget.couponVendor)
                              .then((value) {
                            if (coupon.documentSnapshot == null) {
                              setState(() {
                                coupon.discountRate = 0;
                                _isVisible = false;
                              });
                              EasyLoading.dismiss();
                              showAlertMessage(
                                  couponController.text, "Not Valid");
                              return;
                            }
                            if (coupon.expired == false) {
                              //not expired, coupon is valid
                              setState(() {
                                _isVisible = true;
                              });
                              EasyLoading.dismiss();
                              return;
                            }
                            if (coupon.expired == false) {
                              //not expired, coupon is valid
                              setState(() {
                                _isVisible = true;
                              });
                              EasyLoading.dismiss();
                              showAlertMessage(couponController.text, "Expired");
                            }
                          });
                        },
                        child: const Text(
                          "Apply",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: coupon.documentSnapshot == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DottedBorder(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: const Color.fromRGBO(253, 164, 131, 1),
                                ),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(couponController.text),
                                    ),
                                    Divider(
                                      color: Colors.grey[800],
                                    ),
                                    Text(
                                        "${coupon.documentSnapshot?['details']}"),
                                    Text(
                                        "${coupon.documentSnapshot?['discountRate']} % discount on total purchase"),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                right: -5,
                                top: -6,
                                child: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      coupon.discountRate = 0;
                                      _isVisible = false;
                                      couponController.clear();
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  showAlertMessage(couponCode, validity) {
    showAlert(
        "This discount coupon $couponCode you have entered is $validity.Please try with another code");
  }
}
