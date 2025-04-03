import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking/Authentication/AdminSignUp.dart';
import 'package:parking/Authentication/signIn.dart';
import 'package:parking/Authentication/createParkingSpot.dart';
import 'package:parking/UserDashboard/dashboard.dart';  // Import the CreateParkingSpot screen // Import CustomerView screen
import 'package:parking/Authentication/ownerSignUp.dart';
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => SignIn()));
              },
            ),
          ],
        );
      },
    );
  }

  // Popup menu for the 3 dots icon
  void _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 50, 0, 0), // position of the menu
      items: [
        PopupMenuItem(
          child: Text("Customer View"),
          value: 1,
        ),
        PopupMenuItem(
          child: Text("Logout"),
          value: 2,
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 1) {
        // Navigate to Customer View page
        Navigator.push(
          context,
           MaterialPageRoute(
              builder: (_) {
                // Check if the user is logged in
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Pass the user to the Dashboard if the user is logged in
                  return Dashboard(user: user);
                } else {
                  // If no user is logged in, navigate to the SignIn screen
                  return SignIn();
                }
              },
            ),  // Navigate to CustomerView screen
        );
      } else if (value == 2) {
        _showLogoutDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 1, 69, 54),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white, // 3-dot menu icon
            onPressed: () => _showPopupMenu(context), // Show the menu
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Create Parking Spot button
            ElevatedButton(
              child: Text(
                "Create Parking Spot",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateParkingSpot()), // Navigate to CreateParkingSpot screen
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 1, 69, 54), minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Create Parking Owner Account button
            ElevatedButton(
              child: Text(
                "Create Parking Owner Account",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OwnerSignUp()), // Navigate to OwnerSignUp screen
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 1, 69, 54), minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Create Parking Owner Account button
            ElevatedButton(
              child: Text(
                "Create New Admin Account",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminSignUp()), // Navigate to OwnerSignUp screen
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 1, 69, 54), minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
