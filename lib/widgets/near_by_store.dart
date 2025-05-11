import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../providers/store_provider.dart';
import '../services/store_services.dart';

class NearByStore extends StatefulWidget {
  const NearByStore({super.key});

  @override
  State<NearByStore> createState() => _NearByStoreState();
}

class _NearByStoreState extends State<NearByStore> {
  final StoreServices storeServices = StoreServices();
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final storeData = Provider.of<StoreProvider>(context, listen: false);
      storeData.getUserLocation(context).then((_) {
        setState(() {
          _locationFetched = true;
        });
      });
    });
  }

  String getDistance(location, StoreProvider storeData) {
    var distance = Geolocator.distanceBetween(
      storeData.userLatitude,
      storeData.userLongitude,
      location.latitude,
      location.longitude,
    );
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    if (!_locationFetched) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4, // number of shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 110,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: storeServices.getNearbyStores(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4, // number of shimmer items
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 110,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 150,
                                  height: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          List<double> actualShopDistance = snapshot.data!.docs.map((doc) {
            return Geolocator.distanceBetween(
                  storeData.userLatitude,
                  storeData.userLongitude,
                  doc['location'].latitude,
                  doc['location'].longitude,
                ) /
                1000;
          }).toList();

          actualShopDistance.sort();

          SchedulerBinding.instance.addPostFrameCallback((_) {
            cart.getDistance(actualShopDistance[0]);
          });

          if (actualShopDistance[0] > 10) {
            return Container();
          }

          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: FirestorePagination(
                    shrinkWrap: true,
                    query: storeServices.getNearbyStorePagination(),
                    initialLoader: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 110,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 150,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 80,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    bottomLoader: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        // fewer items since it's just a continuation indicator
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 110,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 150,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 80,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    itemBuilder: (context, snapshot, index) {
                      var documentSnapshot = snapshot[index];

                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 110,
                                child: Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      documentSnapshot['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    documentSnapshot['shopName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    documentSnapshot['dialog'],
                                    style: kStoreCardStyle,
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: Text(
                                      documentSnapshot['address'],
                                      overflow: TextOverflow.ellipsis,
                                      style: kStoreCardStyle,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${getDistance(documentSnapshot['location'], storeData)} km",
                                    style: kStoreCardStyle,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "3.2",
                                        style: kStoreCardStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    controller: ScrollController(),
                    isLive: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
