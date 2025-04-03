import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:parking/Authentication/AdminPage.dart';
import 'package:parking/constant.dart';

class OwnerSignUp extends StatefulWidget {
  const OwnerSignUp({super.key});

  @override
  _OwnerSignUpState createState() => _OwnerSignUpState();
}

class _OwnerSignUpState extends State<OwnerSignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedParkingSpot;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchParkingSpots() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('parkingCenters').get();
    return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }

  void _registerOwnerAccount() async {
    if (_selectedParkingSpot == null) {
      _showErrorDialog("Please select a parking spot.");
      return;
    }

    try {
      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )).user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': _displayName.text,
          'email': user.email,
          'role': 'owner',
          'parkingSpot': _selectedParkingSpot,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Owner Added Successfully"),
            content: Text("Owner account linked to $_selectedParkingSpot successfully created."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Failed to create owner account: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kprimaryBgColor,
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        title: Text("Owner Registration", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Center(child: Image.asset("assets/images/parkmeLogo.png")),
              SizedBox(height: 30),
              Center(
                child: Text(
                  "Create Owner Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Center(
                child: Text(
                  "Please fill in details below!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _displayName,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email ID",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: _fetchParkingSpots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error loading parking spots.");
                  }

                  return DropdownSearch<String>(
                    items: snapshot.data ?? [],
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: "Search Parking Spot",
                        ),
                      ),
                    ),
                   dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Select Parking Spot", // Updated label
                        border: OutlineInputBorder(), // Border of the dropdown input
                        filled: true, // This makes the background of the dropdown light gray
                        fillColor: Colors.grey[200], // Light gray color for the background
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Padding inside the dropdown
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedParkingSpot = value;
                      });
                    },
                    selectedItem: _selectedParkingSpot,
                    
                  );
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _registerOwnerAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kprimaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "SIGN UP",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
