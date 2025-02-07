// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:parking/constant.dart';
// // import 'package:parking/pages/vehicles.dart';
// // import '../pages/map_view.dart';
// // import '../pages/my_profile.dart';

// class Dashboard extends StatefulWidget {
//   final User user;
//   const Dashboard({Key? key, required this.user}) : super(key: key); // Use Key? and required
//   @override
//   _DashboardState createState() => _DashboardState();
// }


// class _DashboardState extends State<Dashboard> {
//   int _currentIndex = 0;
//   // final tabs = [
//   //   MapView(),
//   //   GroupViewPage(),
//   //   MyProfile(
//   //     user: FirebaseAuth.instance.currentUser,
//   //   ),
//   // ];
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     return Container(
//       height: height,
//       width: width,
//       color: Colors.white,
//       child: Scaffold(
//          appBar: AppBar(
//           title: const Text('Dashboard'),
//           backgroundColor: kprimaryColor,
//         ),
//         body: Center(
//           child: const Text(
//             'Welcome to the Dashboard!',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//         ),
//         // body: tabs[_currentIndex],
//         bottomNavigationBar: BottomNavigationBar(
//   currentIndex: _currentIndex,
//   type: BottomNavigationBarType.fixed,
//   items: const <BottomNavigationBarItem>[
//     BottomNavigationBarItem(
//       icon: Icon(Icons.search),
//       label: 'Find', // Use label instead of title
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.directions_car),
//       label: 'My Vehicles', // Use label instead of title
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.person),
//       label: 'My Profile', // Use label instead of title
//     ),
//   ],
//   selectedItemColor: kprimaryColor,
//   onTap: (index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   },
// ),

//       ),

//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/constant.dart';
import 'package:parking/pages/vehicles.dart';
// import '../pages/map_view.dart';
import '../pages/my_profile.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({Key ? key,required this.user}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final tabs = [
    // MapView(),
    GroupViewPage(),
    MyProfile(
      user: FirebaseAuth.instance.currentUser,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      child: Scaffold(
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
             label: 'My Vehicles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Profile',
            ),
          ],
          selectedItemColor: kprimaryColor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),

    );
  }
}

