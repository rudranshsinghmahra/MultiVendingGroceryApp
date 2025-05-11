import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cart_notification.dart';
import '../widgets/categories_widget.dart';
import '../widgets/products/best_selling_products.dart';
import '../widgets/products/featured_products.dart';
import '../widgets/products/recently_added_products.dart';
import '../widgets/vendor_app_bar.dart';
import '../widgets/vendor_banner.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  static const String id = "vendor-home-screen";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                const VendorAppBar(),
              ];
            },
            body: ListView(
              padding: EdgeInsets.zero,
              children: const [
                VendorBanner(),
                VendorCategories(),
                FeaturedProducts(),
                BestSellingProduct(),
                RecentlyAddedProducts(),
              ],
            ),
          ),
          bottomNavigationBar: CartNotification(),
        ),
      ),
    );
  }
}
