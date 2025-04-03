import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateParkingSpot extends StatefulWidget {
  const CreateParkingSpot({super.key});

  @override
  _CreateParkingSpotState createState() => _CreateParkingSpotState();
}

class _CreateParkingSpotState extends State<CreateParkingSpot> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _costPerHourController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _totalSpotsController = TextEditingController();

  int _newSpotId = 0; // New ID to be assigned to the parking spot

  // Function to get the current highest parking spot ID
  Future<void> _fetchCurrentMaxId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('parkingCenters')
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _newSpotId = data['id'] + 1; // Increment the highest ID by 1
      });
    } else {
      setState(() {
        _newSpotId = 1; // If no spots exist, start from ID 1
      });
    }
  }

  void _createParkingSpot() async {
    try {
      await FirebaseFirestore.instance.collection('parkingCenters').add({
        'id': _newSpotId, // Using the auto-generated ID
        'name': _nameController.text,
        'address': _addressController.text,
        'costPerHour': int.parse(_costPerHourController.text),
        'imageUrl': _imageUrlController.text,
        'totalSpots': int.parse(_totalSpotsController.text),
        'occupiedSpots': 0, // Initially no spots are occupied
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Parking Spot Created"),
          content: Text("New parking spot has been successfully added with ID: $_newSpotId."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();  // Go back to AdminPage
              },
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to create parking spot: $e"),
          actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.pop(context))],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentMaxId(); // Fetch the current max ID when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 69, 54),
        title: Text("Create Parking Spot", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Parking Spot Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _costPerHourController,
                decoration: InputDecoration(
                  labelText: "Cost Per Hour",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _totalSpotsController,
                decoration: InputDecoration(
                  labelText: "Total Spots",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createParkingSpot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 69, 54),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Create Spot",
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
