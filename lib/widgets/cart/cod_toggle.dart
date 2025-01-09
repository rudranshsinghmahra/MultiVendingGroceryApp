import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../providers/cart_provider.dart';

class CodToggleSwitch extends StatelessWidget {
  const CodToggleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _cart = Provider.of<CartProvider>(context);
    return Container(
      color: Colors.white,
      // child: ToggleSwitch(
      //   backgroundColor: Colors.grey[600],
      //   textColor: Colors.grey[300],
      //   selectedTabColor: Theme.of(context).primaryColor,
      //   labels: const ["Pay Online", "Cash On Delivery"],
      //   onSelectionUpdated: (index) {
      //     _cart.getPaymentMethod(index);
      //   },
      // ),
    );
  }
}
