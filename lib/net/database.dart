import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  
  final CollectionReference vehiclesCollection = FirebaseFirestore.instance.collection('vehicles');

  Future updateUserData(String title, String owner, String vehicleNumber) async {
    try {
      if (uid != null) {
        // Ensure the document ID is unique, or you can use user-specific ID
        await vehiclesCollection.add({
          'title': title,
          'owner': owner,
          'vehicleNumber': vehicleNumber,
          'uid': uid, // Add the user UID here for Firestore rule validation
        });
      } else {
        throw Exception("User UID is not available.");
      }
    } catch (e) {
      print("Error updating vehicle data: $e");
      throw e; // You can handle this in the calling method
    }
  }
}
