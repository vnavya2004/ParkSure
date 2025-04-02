import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking/Authentication/signIn.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  _OwnerPageState createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String parkingSpotName = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOwnerParkingSpot();
  }

  void _fetchOwnerParkingSpot() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {
      parkingSpotName = userDoc['parkingSpot'];
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignIn()));
            },
          ),
        ],
      ),
    );
  }

  // Function to update the payment status to "Paid"
  void _markAsPaid(String ticketId) async {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Payment Confirmation'),
        content: Text('Is the payment successful?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              // Update the paymentMethod to "Paid"
              await FirebaseFirestore.instance.collection('reservations').doc(ticketId).update({
                'paymentMethod': 'Online', // Change payment method to "Online"
              });

              // Close the dialog and show a success message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment marked as successful')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(String paymentMethod) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .where('centre', isEqualTo: parkingSpotName)
          .where('paymentMethod', isEqualTo: paymentMethod)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $paymentMethod tickets.'));
        }

        var reservations = snapshot.data!.docs.where((doc) {
          final ticketId = doc.id.toLowerCase();
          final vehicleNumber = (doc['vehicleNumber'] as String).toLowerCase();
          final query = searchQuery.toLowerCase();
          return ticketId.contains(query) || vehicleNumber.contains(query);
        }).toList();

        if (reservations.isEmpty) {
          return Center(child: Text('No matching tickets.'));
        }

        return ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            var reservation = reservations[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('Ticket ID: ${reservation.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle: ${reservation['vehicleNumber']}'),
                    Text('From: ${reservation['checkinDate']} at ${reservation['checkin']}'),
                    Text('To: ${reservation['checkoutDate']} at ${reservation['checkout']}'),
                    Text('Cost: ₹${reservation['cost']}'),
                    if (paymentMethod == 'Online' && reservation['transactionID'] != null)
                      Text('Txn ID: ${reservation['transactionID']}'),
                  ],
                ),
                leading: Icon(
                  paymentMethod == 'Online' ? Icons.payment : Icons.money_off,
                  color: paymentMethod == 'Online' ? Colors.green : Colors.orange,
                ),
                trailing: paymentMethod == 'On Arrival'
                    ? IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _markAsPaid(reservation.id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 69, 54),
        title: Text("Owner Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
        bottom: TabBar(
  controller: _tabController,
  indicatorColor: Colors.white, // Indicator color remains white
  labelColor: Colors.white,     // Text color for the selected tab
  unselectedLabelColor: Colors.white70, // Text color for the unselected tabs (lightened white)
  tabs: [
    Tab(
      icon: Icon(Icons.money_off, color: Colors.white), // Icon color for the first tab
      text: 'Pay at Location',
    ),
    Tab(
      icon: Icon(Icons.payment, color: Colors.white),  // Icon color for the second tab
      text: 'Paid (Online)',
    ),
  ],
)

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Ticket ID or Vehicle No',
                hintStyle: TextStyle(fontSize: 14),  // Reduced font size
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: TextStyle(fontSize: 14),  // Reduced input text size
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationsList('On Arrival'),
                _buildReservationsList('Online'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
