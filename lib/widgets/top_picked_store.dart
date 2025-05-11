import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/store_provider.dart';
import '../screens/vendors_home_screen.dart';
import '../services/store_services.dart';

class TopPickedStore extends StatefulWidget {
  const TopPickedStore({super.key});

  @override
  State<TopPickedStore> createState() => _TopPickedStoreState();
}

class _TopPickedStoreState extends State<TopPickedStore> {
  late Future<void> _locationFuture;

  @override
  void initState() {
    super.initState();
    final storeData = Provider.of<StoreProvider>(context, listen: false);
    _locationFuture = storeData.getUserLocation(context);
  }

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);

    return FutureBuilder(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return  ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,  // Placeholder shimmer items
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 15,
                          width: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 12,
                          width: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        print("Lat: ${storeData.userLatitude}, Lng: ${storeData.userLongitude}");

        String getDistance(location) {
          var distance = Geolocator.distanceBetween(storeData.userLatitude,
              storeData.userLongitude, location.latitude, location.longitude);
          var distanceInKm = distance / 1000;
          return distanceInKm.toStringAsFixed(2);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: StoreServices().getTopPickedStore(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 20),
                      child: Row(
                        children: [
                          SizedBox(height: 30, child: Icon(Icons.store, size: 30)),
                          SizedBox(width: 10),
                          Text(
                            "Top Picked Store Near To You",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 20),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,  // Placeholder shimmer items
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                width: 80,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 15,
                                      width: 60,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 12,
                                      width: 40,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            List actualShopDistance = [];
            for (int i = 0; i <= snapshot.data!.docs.length - 1; i++) {
              var distance = Geolocator.distanceBetween(
                storeData.userLatitude,
                storeData.userLongitude,
                snapshot.data?.docs[i]['location'].latitude,
                snapshot.data?.docs[i]['location'].longitude,
              );
              var distanceInKm = distance / 1000;
              actualShopDistance.add(distanceInKm);
            }
            actualShopDistance.sort();

            if (actualShopDistance[0] > 10) {
              return Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "No Store Within 10km",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Row(
                      children: [
                        SizedBox(height: 30, child: Image.asset('assets/like.gif')),
                        const SizedBox(width: 10),
                        const Text(
                          "Top Picked Store Near To You",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!.docs.map(
                            (DocumentSnapshot document) {
                          if (double.parse(getDistance(document['location'])) <= 10) {
                            return InkWell(
                              onTap: () {
                                storeData.getSelectedStore(
                                    document, getDistance(document['location']));
                                pushScreen(context, screen: VendorHomeScreen());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 80,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Card(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              document['imageUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                        child: Text(
                                          document['shopName'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        "${getDistance(document['location'])}km",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 20, top: 20),
                                  child: Text(
                                    "No Store Within 10km",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            );
                          }
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
