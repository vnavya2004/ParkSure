import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking/Authentication/ownerSignUp.dart';
import 'package:parking/Authentication/signIn.dart';

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
            icon: Icon(Icons.logout),
            color:  Colors.white,
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Create Parking Owner Account",style: TextStyle(fontSize: 16, color: Colors.black)),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => OwnerSignUp()));
          },
        ),
      ),
    );
  }
}
