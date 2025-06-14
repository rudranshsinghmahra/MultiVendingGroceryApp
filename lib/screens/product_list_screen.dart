import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../widgets/products/product_filter_widget.dart';
import '../widgets/products/product_list.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});
  static const String id = 'product-list-screen';
  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              floating: true,
              snap: true,
              title: Text(
                storeProvider.selectedProductCategory.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              expandedHeight: 140,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 117),
                child: Container(
                  height: 56,
                  color: Colors.grey,
                  child: ProductFilterWidget(),
                ),
              ),
            )
          ];
        },
        body: ListView(
          padding: EdgeInsets.zero,
          children: const [
            ProductListWidget(),
          ],
        ),
      ),
    );
  }
}
