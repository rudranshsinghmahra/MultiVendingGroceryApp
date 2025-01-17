import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../providers/store_provider.dart';
import '../services/store_services.dart';

class NearByStore extends StatefulWidget {
  const NearByStore({Key? key}) : super(key: key);

  @override
  State<NearByStore> createState() => _NearByStoreState();
}

class _NearByStoreState extends State<NearByStore> {
  StoreServices storeServices = StoreServices();

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    storeData.getUserLocation(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(
        storeData.userLatitude,
        storeData.userLongitude,
        location.latitude,
        location.longitude,
      );
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: storeServices.getNearbyStores(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<double> actualShopDistance = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              var distance = Geolocator.distanceBetween(
                storeData.userLatitude,
                storeData.userLongitude,
                snapshot.data!.docs[i]['location'].latitude,
                snapshot.data!.docs[i]['location'].longitude,
              );
              var distanceInKm = distance / 1000;
              actualShopDistance.add(distanceInKm);
            }
            actualShopDistance.sort();

            SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                  cart.getDistance(actualShopDistance[0]);
                }));
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
                      initialLoader: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      itemBuilder: (context, snapshot, index) {
                        var documentSnapshot =
                            snapshot[index]; // Access the document directly
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
                                        // Access the document data
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
                                      // Access the document data
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
                                      // Access the document data
                                      style: kStoreCardStyle,
                                    ),
                                    const SizedBox(height: 3),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width - 250,
                                      child: Text(
                                        documentSnapshot['address'],
                                        // Access the document data
                                        overflow: TextOverflow.ellipsis,
                                        style: kStoreCardStyle,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "${getDistance(documentSnapshot['location'])} km",
                                      // Access the document data
                                      overflow: TextOverflow.ellipsis,
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
          }
        },
      ),
    );
  }
}
