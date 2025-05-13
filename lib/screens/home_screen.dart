import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/images_slider.dart';
import '../widgets/my_appbar.dart';
import '../widgets/near_by_store.dart';
import '../widgets/top_picked_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? location = "";

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    setState(() {
      this.location = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            body: ListView(
              children: const [
                ImageSlider(),
                SizedBox(
                  height: 220,
                  child: TopPickedStore(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: NearByStore(),
                ),
              ],
            ),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                const PreferredSize(
                  preferredSize: Size.fromHeight(130),
                  child: MyAppBar(),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }
}
