// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:parking/booking/Booking_Confirmation.dart';
// import 'package:parking/constant.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MapView extends StatefulWidget {
//   @override
//   _MapViewState createState() => _MapViewState();
// }

// class _MapViewState extends State<MapView> {
//   final CameraPosition _initialLocation =
//   CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5);
//   GoogleMapController mapController;
//   final Geolocator _geolocator = Geolocator();
//   Position _currentPosition;
//   final myController = TextEditingController();
//   bool _showClearButton = false;
//   Set<Marker> markers = {};
//   BitmapDescriptor _mapMarker;
//   BuildContext mContext;
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   void dispose() {
//     myController.dispose();
//     super.dispose();
//   }

//   void customMarker() async {
//     // ignore: deprecated_member_use
//     _mapMarker = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(), 'assets/images/parkmeIcon.png');
//   }

//   void closeModal() {
//     Navigator.pop(mContext);
//   }

//   void addMarkers() async {
//     //List _spots;
//      await firestore
//         .collection('parkingCenters')
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       querySnapshot.docs.forEach((spot) async {
//         List<Placemark> marker =
//             await _geolocator.placemarkFromAddress(spot['address']);
//         Position markerCoordinates = marker[0].position;
//         Marker destinationMarker = Marker(
//           onTap: () {
//             showModalBottomSheet<void>(
//               context: context,
//               builder: (BuildContext context) {
//                 mContext = context;
//                 return Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 250,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(10),
//                         topLeft: Radius.circular(10)),
//                     color: Colors.white70,
//                   ),
//                   child: Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
//                     child: Column(
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Column(
//                               children: [
//                                 Hero(
//                                   tag: 'centerName',
//                                   child: Text(
//                                     spot['name'],
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: kprimaryColor,
//                                         fontSize: 20),
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.location_on,
//                                       size: 15,
//                                     ),
//                                     Text(spot['address']),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         IntrinsicHeight(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       '\u{20B9} ${spot['costPerHour']}',
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                     Text('per hour')
//                                   ],
//                                 ),
//                                 VerticalDivider(
//                                   thickness: 2,
//                                   width: 20,
//                                   color: Colors.black26,
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       (spot['totalSpots'] -
//                                           spot['occupiedSpots'])
//                                           .toString(),
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                     Text('seats left')
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width,
//                           child: FlatButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5.0)),
//                             padding: EdgeInsets.all(10),
//                             splashColor: Colors.blue,
//                             color: kprimaryColor,
//                             child: const Text(
//                               'RESERVE',
//                               style: TextStyle(color: Colors.white, fontSize: 18),
//                               textAlign: TextAlign.center,
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (_) {
//                                     return BookingConfirmation(
//                                       spot: spot,
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//           // Plotting the marker
//           markerId: MarkerId('$markerCoordinates'),
//           position: LatLng(
//             markerCoordinates.latitude,
//             markerCoordinates.longitude,
//           ),
//           infoWindow: InfoWindow(
//             title: spot['name'],
//           ),
//           icon: _mapMarker,
//         );
//         markers.add(destinationMarker);
//       });
//     });
//   }

//   _updateLocation(address) async {
//     List<Placemark> destinationPlacemark =
//         await _geolocator.placemarkFromAddress(address);
//     Position destinationCoordinates = destinationPlacemark[0].position;

//     setState(() {
//       mapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(destinationCoordinates.latitude,
//                 destinationCoordinates.longitude),
//             zoom: 15.0,
//           ),
//         ),
//       );
//     });
//   }

//   _getCurrentLocation() async {
//     await _geolocator
//         .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) async {
//       setState(() {
//         _currentPosition = position;
//         mapController.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15.0,
//             ),
//           ),
//         );
//       });
//     }).catchError((e) {
//       print(e);
//     });
//   }

//   _getClearButton() {
//     if (!_showClearButton) {
//       return null;
//     }
//     return IconButton(
//       onPressed: () => myController.clear(),
//       icon: Icon(Icons.clear),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     customMarker();
//     _getCurrentLocation();
//     addMarkers();
//     myController.addListener(() {
//       setState(() {
//         _showClearButton = myController.text.length > 0;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     return Container(
//       height: height,
//       width: width,
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             GoogleMap(
//               initialCameraPosition: _initialLocation,
//               markers: markers,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               mapType: MapType.normal,
//               zoomGesturesEnabled: true,
//               zoomControlsEnabled: false,
//               onMapCreated: (GoogleMapController controller) {
//                 mapController = controller;
//               },
//             ),
//             SafeArea(
//               child: Align(
//                 alignment: Alignment.bottomLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
//                   child: ClipOval(
//                     child: Material(
//                       color: kprimaryColor,
//                       child: InkWell(
//                         splashColor: Colors.blue,
//                         child: SizedBox(
//                           width: 56,
//                           height: 56,
//                           child: Icon(Icons.my_location, color: kBtnTextColor),
//                         ),
//                         onTap: () {
//                           mapController.animateCamera(
//                             CameraUpdate.newCameraPosition(
//                               CameraPosition(
//                                 target: LatLng(
//                                   _currentPosition.latitude,
//                                   _currentPosition.longitude,
//                                 ),
//                                 zoom: 15.0,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SafeArea(
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 child: TextField(
//                   controller: myController,
//                   onSubmitted: (text) => _updateLocation(myController.text),
//                   style: TextStyle(
//                     fontSize: 18,
//                   ),
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 25, vertical: 18),
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: 'Search here',
//                     suffixIcon: _getClearButton(),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(width: 0, color: Colors.white),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(width: 0, color: Colors.white),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 20,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geocoding/geocoding.dart';

// class MapView extends StatefulWidget {
//   @override
//   _MapViewState createState() => _MapViewState();
// }

// class _MapViewState extends State<MapView> {
//   final CameraPosition _initialLocation =
//       CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5);
//   late GoogleMapController mapController;
//   late Position _currentPosition;
//   final myController = TextEditingController();
//   bool _showClearButton = false;
//   Set<Marker> markers = {};
//   late BitmapDescriptor _mapMarker;
//   late BuildContext mContext;
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     customMarker();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Map View")),
//       body: GoogleMap(
//         initialCameraPosition: _initialLocation,
//         markers: markers,
//         onMapCreated: (GoogleMapController controller) {
//           mapController = controller;
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     myController.dispose();
//     super.dispose();
//   }

//   void customMarker() async {
//     _mapMarker = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(), 'assets/images/parkmeIcon.png');
//   }

//   void closeModal() {
//     Navigator.pop(mContext);
//   }

//   void addMarkers() async {
//     await firestore.collection('parkingCenters').get().then((QuerySnapshot querySnapshot) {
//       for (var spot in querySnapshot.docs) {
//         _getCoordinatesFromAddress(spot['address']).then((LatLng coordinates) {
//           Marker destinationMarker = Marker(
//             onTap: () {
//               showModalBottomSheet<void>(
//                 context: context,
//                 builder: (BuildContext context) {
//                   mContext = context;
//                   return Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 250,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(10),
//                           topLeft: Radius.circular(10)),
//                       color: Colors.white70,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
//                       child: Column(
//                         children: <Widget>[
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Column(
//                                 children: [
//                                   Hero(
//                                     tag: 'centerName',
//                                     child: Text(
//                                       spot['name'],
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.blue,
//                                           fontSize: 20),
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.location_on, size: 15),
//                                       Text(spot['address']),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           IntrinsicHeight(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         '\u{20B9} ${spot['costPerHour']}',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       Text('per hour')
//                                     ],
//                                   ),
//                                   VerticalDivider(thickness: 2, width: 20, color: Colors.black26),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         (spot['totalSpots'] - spot['occupiedSpots']).toString(),
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       Text('seats left')
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.all(10),
//                                 backgroundColor: Colors.blue,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(5.0),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'RESERVE',
//                                 style: TextStyle(color: Colors.white, fontSize: 18),
//                                 textAlign: TextAlign.center,
//                               ),
//                               onPressed: () {
//                                 // Implement reservation functionality here
//                               },
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//             markerId: MarkerId(coordinates.toString()),
//             position: coordinates,
//             infoWindow: InfoWindow(title: spot['name']),
//             icon: _mapMarker,
//           );
//           setState(() {
//             markers.add(destinationMarker);
//           });
//         });
//       }
//     });
//   }  

//   Future<LatLng> _getCoordinatesFromAddress(String address) async {
//     try {
//       List<Location> locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         return LatLng(locations[0].latitude, locations[0].longitude);
//       }
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//     return LatLng(0.0, 0.0); // Default fallback location
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:parking/booking/Booking_Confirmation.dart';
import 'package:parking/constant.dart';
import 'package:parking/booking/SpeechToBooking.dart';
import 'package:permission_handler/permission_handler.dart';


class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final CameraPosition _initialLocation =
      CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5);
  late GoogleMapController mapController;
  // ignore: unused_field
  late Position _currentPosition;
  final myController = TextEditingController();
  bool _showClearButton = false;
  Set<Marker> markers = {};
  late BitmapDescriptor _mapMarker;
  late BuildContext mContext;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    customMarker();
    _getCurrentLocation();
    addMarkers();

    // Listener for the search bar clear button
    myController.addListener(() {
      setState(() {
        _showClearButton = myController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map View")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialLocation,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
               print("Map Loaded Successfully");
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      splashColor: Colors.lightBlue,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location, color: Colors.white),
                      ),
                      onTap: () {
                        _getCurrentLocation();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: myController,
                onSubmitted: (text) => _updateLocation(text),
                style: TextStyle(fontSize: 18),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search here',
                  suffixIcon: _getClearButton(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.white),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.white),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
  child: Align(
    alignment: Alignment.bottomRight,  // Bottom Right Corner
    child: Padding(
      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: ClipOval(
        child: Material(
          color: Colors.red,  // Mic button color
          child: InkWell(
            splashColor: Colors.redAccent,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.mic, color: Colors.white),
            ),
           onTap: () async {
            await _handleMicPermissionAndNavigate();
          },


          ),
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
void _navigateToSpeechToBooking() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SpeechToBooking()),
  );
}


Future<void> _handleMicPermissionAndNavigate() async {
  var status = await Permission.microphone.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.microphone.request();
  }

  if (status.isGranted) {
    _navigateToSpeechToBooking();
  } else if (status.isPermanentlyDenied) {
    
    _showPermissionDialog();
  } else {
    // Show toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Microphone permission is required."),
        backgroundColor: Colors.red,
      ),
    );
  }
}
void _showPermissionDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text("Microphone Access Required"),
      content: Text("To use voice booking, please allow microphone access."),
      actions: [
        TextButton(
          child: Text("Open Settings"),
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}



  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void customMarker() async {
    // ignore: deprecated_member_use
    _mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/parkmeIcon.png');
  }

  void closeModal() {
    Navigator.pop(mContext);
  }

 void addMarkers() async {
  await firestore.collection('parkingCenters').get().then((QuerySnapshot querySnapshot) {
    for (var spot in querySnapshot.docs) {
      _getCoordinatesFromAddress(spot['address']).then((LatLng coordinates) {
        Marker destinationMarker = Marker(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          spot['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Icon(Icons.location_on, size: 15),
                        //     SizedBox(width: 5),
                        //     Expanded(
                        //       child: Text(
                        //         spot['address'],
                        //         overflow: TextOverflow.ellipsis,
                        //         maxLines: 2,
                        //         textAlign: TextAlign.center,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Divider(thickness: 1, height: 20, color: Colors.black26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '₹ ${spot['costPerHour']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text('per hour'),
                              ],
                            ),
                            VerticalDivider(thickness: 2, width: 20, color: Colors.black26),
                            Column(
                              children: [
                                Text(
                                  (spot['totalSpots']).toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text('Total Spots'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kprimaryColor,
                              padding: EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookingConfirmation(
                                    key: UniqueKey(),
                                    spot: spot,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'RESERVE',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          markerId: MarkerId(coordinates.toString()),
          position: coordinates,
          infoWindow: InfoWindow(title: spot['name']),
          icon: _mapMarker,
        );
        setState(() {
          markers.add(destinationMarker);
        });
      });
    }
  });
}


  Future<LatLng> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
    return LatLng(0.0, 0.0);
  }

void _getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }
  }

  if (permission == LocationPermission.denied) {
    print('Location permissions are denied.');
    return;
  }

  Position position = await Geolocator.getCurrentPosition(
    // ignore: deprecated_member_use
    desiredAccuracy: LocationAccuracy.high,
  );

  setState(() {
    _currentPosition = position;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  });
}


  void _updateLocation(String address) async {
    LatLng destinationCoordinates = await _getCoordinatesFromAddress(address);
    setState(() {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: destinationCoordinates, zoom: 15.0),
        ),
      );
    });
  }

  Widget? _getClearButton() {
    return _showClearButton
        ? IconButton(
            onPressed: () => myController.clear(),
            icon: Icon(Icons.clear),
          )
        : null;
  }
}