import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/products/bottom_sheet_container.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, this.documentSnapshot});

  static const String id = "product_details_screen";
  final DocumentSnapshot? documentSnapshot;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var offer = (((widget.documentSnapshot?['comparedPrice']) -
        (widget.documentSnapshot?['price'])) /
        widget.documentSnapshot?['comparedPrice'] *
        100);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom),
        child: BottomSheetContainer(documentSnapshot: widget.documentSnapshot),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 8),
                    child: Text(widget.documentSnapshot?['brand']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.documentSnapshot?['productName'],
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              widget.documentSnapshot?['weight'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Rs ${widget.documentSnapshot?['price'].toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                if (offer > 0)
                  Text(
                    "Rs ${widget.documentSnapshot?['comparedPrice']}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough),
                  ),
                const SizedBox(width: 10),
                if (offer > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        "${offer.toStringAsFixed(0)}% Off",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Hero(
                tag: "product${widget.documentSnapshot?['productName']}",
                child: Image.network(widget.documentSnapshot?['productImage']),
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 6),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "About This Product",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 6),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandableText(
                widget.documentSnapshot?['description'],
                expandText: 'View More',
                collapseText: 'View Less',
                maxLines: 2,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            Divider(color: Colors.grey[400]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Other Product Information",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SKU: ${widget.documentSnapshot?['sku']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Seller: ${widget.documentSnapshot?['seller']['shopName']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
