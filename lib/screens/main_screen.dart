import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../widgets/cart/cart_notification.dart';
import 'favourite_screen.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String id = 'main-screen-page';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  List<PersistentTabConfig> navBarsTabs() {
    return [
      PersistentTabConfig(
        item: ItemConfig(
          icon: Image.asset('assets/logo.png'),
          title: "Home",
          activeForegroundColor: Theme.of(context).primaryColor,
          inactiveForegroundColor: CupertinoColors.systemGrey,
        ),
        screen: HomeScreen(),
      ),
      PersistentTabConfig(
        item: ItemConfig(
          icon: Icon(CupertinoIcons.square_favorites_alt),
          title: "My Favourites",
          activeForegroundColor: Theme.of(context).primaryColor,
          inactiveForegroundColor: CupertinoColors.systemGrey,
        ),
        screen: FavouriteScreen(),
      ),
      PersistentTabConfig(
        item: ItemConfig(
          icon: Icon(CupertinoIcons.bag),
          title: "My Orders",
          activeForegroundColor: Theme.of(context).primaryColor,
          inactiveForegroundColor: CupertinoColors.systemGrey,
        ),
        screen: MyOrdersScreen(),
      ),
      PersistentTabConfig(
        item: ItemConfig(
          icon: Icon(CupertinoIcons.profile_circled),
          title: "My Account",
          activeForegroundColor: Theme.of(context).primaryColor,
          inactiveForegroundColor: CupertinoColors.systemGrey,
        ),
        screen: ProfileScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        tabs: navBarsTabs(),
        avoidBottomPadding: true,
        navBarBuilder: (navBarConfig) => Style9BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(color: Colors.white),
        ),
        navBarHeight: 56,
        controller: controller,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        gestureNavigationEnabled: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: controller.index == 3 || controller.index == 2
            ? Container()
            : Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: CartNotification(),
            ),
      ),
    );
  }
}
