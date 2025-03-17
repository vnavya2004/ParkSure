import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constant.dart';
import 'BookingSuccessful.dart';

class MyBooking extends StatefulWidget {
  @override
  _MyBookingState createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Bookings',
          style: TextStyle(color: kBtnTextColor),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservations')
                .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  var data = document.data() as Map<String, dynamic>?; // ✅ Handle null case
                  if (data == null) return SizedBox.shrink(); // Hide empty data

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(data['centre'] ?? 'N/A'),
                          subtitle: Text('Date: ${data['date'] ?? 'N/A'}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) {
                                  return BookingSuccessful(
                                    key: UniqueKey(), // ✅ Added key
                                    spot: document as QueryDocumentSnapshot<Object?>,
                                    data: {
                                      'ticketID': document.id,
                                      'centre': data['centre'] ?? 'N/A',
                                      'date': data['date'] ?? 'N/A',
                                      'checkin': data['checkin'] ?? 'N/A',
                                      'checkout': data["checkout"] ?? 'N/A',
                                      'cost': data["cost"] ?? '0',
                                      'vehicleNumber': data["vehicleNumber"] ?? 'N/A',
                                      'transactionID': data["transactionID"] ?? '',
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
      ),
    );
  }
}
