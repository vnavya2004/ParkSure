import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditParkingSpotPage extends StatefulWidget {
  const EditParkingSpotPage({Key? key}) : super(key: key);

  @override
  _EditParkingSpotPageState createState() => _EditParkingSpotPageState();
}

class _EditParkingSpotPageState extends State<EditParkingSpotPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _totalSpotsController = TextEditingController();
  String name = ''; // Store parking spot name
  String address = ''; // Store parking spot address

  @override
  void initState() {
    super.initState();
    _fetchParkingSpotDetails();
  }

  // Fetch parking spot details from Firestore based on the parking spot name
  Future<void> _fetchParkingSpotDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the parking spot name assigned to this user from Firestore (assuming it's in users collection)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String? parkingSpotName = userDoc['parkingSpot'];  // Assuming this field stores parking spot name

      if (parkingSpotName != null) {
        // Now fetch parking spot details from parkingCenters collection using the name
        QuerySnapshot spotDocs = await FirebaseFirestore.instance.collection('parkingCenters')
            .where('name', isEqualTo: parkingSpotName) // Query by name
            .get();

        if (spotDocs.docs.isNotEmpty) {
          // Set the fetched details in the variables
          var spotDoc = spotDocs.docs[0]; // Assuming parking spot name is unique
          setState(() {
            name = spotDoc['name'] ?? '';
            address = spotDoc['address'] ?? '';
            _costController.text = spotDoc['costPerHour'].toString() ?? '';
            _totalSpotsController.text = spotDoc['totalSpots'].toString() ?? '';
          });
        }
      }
    }
  }

  // Update the parking spot details in Firestore
  Future<void> _updateParkingSpot() async {
    try {
      // Get the updated data for cost per hour and total spots
      double costPerHour = double.parse(_costController.text.trim());
      int totalSpots = int.parse(_totalSpotsController.text.trim());

      // Update the parking spot details in Firestore
      QuerySnapshot spotDocs = await FirebaseFirestore.instance.collection('parkingCenters')
          .where('name', isEqualTo: name) // Use name to find the spot
          .get();

      if (spotDocs.docs.isNotEmpty) {
        var spotDoc = spotDocs.docs[0]; // Assuming parking spot name is unique
        String parkingSpotId = spotDoc.id;

        // Update the parking spot document
        await FirebaseFirestore.instance.collection('parkingCenters').doc(parkingSpotId).update({
          'costPerHour': costPerHour,
          'totalSpots': totalSpots,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Parking Spot Updated Successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update parking spot: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Parking Spot', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 1, 69, 54),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Spot Name (display only)
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text('Name: $name', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              // Parking Spot Address (display only)
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text('Address: $address', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              // Cost per Hour (editable)
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text('Cost per Hour:', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: TextField(
                    controller: _costController,
                    decoration: InputDecoration(hintText: 'Enter Cost per Hour'),
                    keyboardType: TextInputType.number,
                  ),
                  trailing: Icon(Icons.edit),
                ),
              ),
              
              // Total Spots (editable)
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text('Total Spots:', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: TextField(
                    controller: _totalSpotsController,
                    decoration: InputDecoration(hintText: 'Enter Total Spots'),
                    keyboardType: TextInputType.number,
                  ),
                  trailing: Icon(Icons.edit),
                ),
              ),

              // Save Changes Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: _updateParkingSpot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 1, 69, 54),
                    minimumSize: Size(double.infinity, 50), // Full width button
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
