import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:parking/authentication/signIn.dart';
import 'package:parking/UserDashboard/ChangePassword.dart';
import 'package:parking/booking/mybooking.dart';
import 'package:parking/constant.dart';
import 'package:parking/pages/EditParkingSpotPage.dart';
import 'package:parking/pages/faq.dart';// Import EditParkingSpotPage

class MyProfile extends StatefulWidget {
  final User? user;
  const MyProfile({Key? key, required this.user}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userRole = ''; // Store user role

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Fetch the user role on profile page load
  }

  // Fetch user role from Firestore
  void _fetchUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user?.uid).get();
    setState(() {
      userRole = userDoc['role'] ?? ''; // Retrieve role from Firestore
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Profile(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        "Welcome, ${widget.user?.displayName ?? "User"}",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "${widget.user?.email}",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text('Account Settings'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: ProfileOptions(
                            icon: Icons.settings,
                            Option_title: 'Change Password'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return ChangePassword(
                                  user: _auth.currentUser,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        child: ProfileOptions(
                            icon: Icons.question_answer,
                            Option_title: 'Frequently Asked Questions'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return FAQPage();
                              },
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        child: ProfileOptions(
                            icon: Icons.store, Option_title: 'My Bookings'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return MyBooking();
                              },
                            ),
                          );
                        },
                      ),
                      // Show "Edit Parking Spot" option only if the user is an owner
                      if (userRole == 'owner') 
                        GestureDetector(
                          child: ProfileOptions(
                              icon: Icons.edit, Option_title: 'Edit Parking Spot'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) {
                                  return EditParkingSpotPage(); // Navigate to EditParkingSpotPage
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    _signOut().whenComplete(() {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => SignIn()));
                    });
                  },
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kprimaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Text('ParkSure v1.0.0')
            ],
          ),
        ),
      ),
    );
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  Profile() {
    if (widget.user?.photoURL != null) {
      String photoUrl = widget.user?.photoURL?.replaceFirst("s96", "s400") ?? "";
      print(photoUrl);
      return CircleAvatar(
        radius: 65,
        backgroundImage: NetworkImage(photoUrl),
      );
    }
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
          color: kprimaryColor,
          borderRadius: BorderRadius.all(Radius.circular(100))),
      child: Center(
          child: Text(
        (widget.user?.displayName?.isNotEmpty ?? false)
            ? widget.user!.displayName![0]
            : '?',
        style: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      )),
    );
  }
}

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({
    Key? key,
    required this.icon,
    required this.Option_title,
  }) : super(key: key);

  final IconData icon;
  final String Option_title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(Option_title),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}
