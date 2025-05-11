import 'package:flutter/material.dart';

class BillingDetailsWidget extends StatelessWidget {
  final double subTotal;
  final double discount;
  final double deliveryFee;
  final double payable;
  final double savings;
  final TextStyle textStyle;

  const BillingDetailsWidget({
    super.key,
    required this.subTotal,
    required this.discount,
    required this.deliveryFee,
    required this.payable,
    required this.savings,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  "Billing Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Basket Value",
                        style: textStyle,
                      ),
                    ),
                    Text(
                      subTotal.toStringAsFixed(0),
                      style: textStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (discount > 0)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Discount",
                          style: textStyle,
                        ),
                      ),
                      Text(
                        "- \Rs ${discount.toStringAsFixed(0)}",
                        style: textStyle,
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Delivery",
                        style: textStyle,
                      ),
                    ),
                    Text(
                      "Rs $deliveryFee",
                      style: textStyle,
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Total Amount Payable",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "\Rs ${payable.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Total Saving",
                            style: TextStyle(color: Colors.deepPurpleAccent),
                          ),
                        ),
                        Text(
                          "Rs ${savings.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.deepPurpleAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
