import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking/booking/BookingSuccessful.dart';
import 'package:parking/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:http/http.dart' as http;

class BookingConfirmation extends StatefulWidget {
  final QueryDocumentSnapshot spot;
  const BookingConfirmation({required Key key, required this.spot}) : super(key: key);
  @override
  _BookingConfirmationState createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  late TimeOfDay _checkInTime, _checkOutTime;
  late DateTime _date;
  DateTime? _checkInDate;
DateTime? _checkOutDate;
  String? dropdownValue = null;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  late int currentOccupiedSpots;
  List _vehicles = [];
  final Razorpay _razorpay = Razorpay();
  late TwilioFlutter twilioFlutter;
  @override
  void initState() {
    _initUserVehicles();
    _checkInTime = TimeOfDay.now();
    _checkOutTime = TimeOfDay.now();
    _checkInDate = DateTime.now();
_checkOutDate = DateTime.now();
    _date = DateTime.now();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    twilioFlutter = TwilioFlutter(
        accountSid : '*********************',
        authToken : '****************************',
        twilioNumber : '****************'
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
        constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height,
    ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsetsDirectional.only(top: 5),
                  height: height * 0.25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.spot['imageUrl']),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  top: 250,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: kprimaryBgColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: kprimaryBgColor,
                    child: Center(
                      child: GestureDetector(
                        child: Icon(Icons.arrow_back, color: kprimaryColor),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              // height: height * 0.60,
              decoration: BoxDecoration(
                color: kprimaryBgColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Hero(
                              tag: 'centerName',
                              child: Text(
                                widget.spot['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kprimaryColor,
                                    fontSize: 18),
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Icon(
                            //       Icons.location_on,
                            //       size: 18,
                            //     ),
                            //     Text(
                            //       widget.spot['address'],
                            //       style: TextStyle(fontSize: 16),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Container(
                        //   margin: EdgeInsets.only(top: 12, bottom: 10),
                        //   height: 30,
                        //   width: 150,
                        //   child: Center(
                        //     child: Text(
                        //       '${widget.spot['totalSpots'] - widget.spot['occupiedSpots']} slots available',
                        //       style: TextStyle(
                        //           color: Colors.red,
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold),
                        //     ),
                        //   ),
                        //   decoration: BoxDecoration(
                        //       color: Colors.red.shade100,
                        //       borderRadius: BorderRadius.circular(5)),
                        // ),
                        Container(
                        margin: EdgeInsets.only(top: 12, bottom: 10),
                        height: 30,
                        width: 180,
                        child: FutureBuilder<int>(
                          future: getAvailableSlots(), // Fetch dynamic available slots
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator()); // Show loading
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Error loading slots"));
                            } else {
                              return Center(
                                child: Text(
                                  '${snapshot.data} slots available',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      ],
                    ),
                    Text(
                      '\u{20B9} ${widget.spot['costPerHour']} per hour',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 20),
                      child: Divider(color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // ✅ Check-in Section
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text("Check-in", style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                    context: context, initialTime: _checkInTime);
                if (time != null) {
                  setState(() {
                    _checkInTime = time;
                  });
                }
              },
              child: Container(
                width: width * 0.35,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  "${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: _checkInDate!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _checkInDate = date;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_checkInDate!),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ),
            Text("(Tap to edit)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),

        // ✅ Check-out Section
        Column(
          children: [
            Text("Check-out", style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                    context: context, initialTime: _checkOutTime);
                if (time != null) {
                  setState(() {
                    _checkOutTime = time;
                  });
                }
              },
              child: Container(
                width: width * 0.35,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  "${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: _checkOutDate!,
                  firstDate: _checkInDate ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _checkOutDate = date;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_checkOutDate!),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ),
            Text("(Tap to edit)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    )
  ],
),

                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: DropdownButton<String>(
                              // ignore: unnecessary_null_comparison
                              hint: dropdownValue == null
                                  ? Text('Choose Vehicle')
                                  : Text(
                                      dropdownValue!,
                                    ),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 30,
                              elevation: 24,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              underline: Container(
                                height: 2,
                                color: Colors.grey.shade200,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                ..._vehicles
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Text(
                          'Total Charges',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          '\u{20B9} ${(DateTime(
                              _checkOutDate!.year,
                              _checkOutDate!.month,
                              _checkOutDate!.day,
                              _checkOutTime.hour,
                              _checkOutTime.minute,
                            ).difference(DateTime(
                              _checkInDate!.year,
                              _checkInDate!.month,
                              _checkInDate!.day,
                              _checkInTime.hour,
                              _checkInTime.minute,
                            )).inMinutes / 60 * widget.spot['costPerHour']).ceil()}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),                         
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
           Row(
  children: <Widget>[
    Container(
      width: width * 0.5,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          padding: EdgeInsets.all(10),
          backgroundColor: Colors.grey.shade200,
        ),
        child: const Text(
          'PAY AT LOCATION',
          style: TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        onPressed: () async {
            DateTime checkInDateTime = DateTime(
  _checkInDate!.year,
  _checkInDate!.month,
  _checkInDate!.day,
  _checkInTime.hour,
  _checkInTime.minute,
);
DateTime checkOutDateTime = DateTime(
  _checkOutDate!.year,
  _checkOutDate!.month,
  _checkOutDate!.day,
  _checkOutTime.hour,
  _checkOutTime.minute,
);

if (checkInDateTime.isBefore(DateTime.now())) {
  Fluttertoast.showToast(msg: "Check-in time must be in the future");
  return;
}
if (!checkOutDateTime.isAfter(checkInDateTime)) {
  Fluttertoast.showToast(msg: "Check-out must be after check-in");
  return;
}

int availableSlots = await getAvailableSlots();
if (availableSlots > 0) {
  addReservationToFirebase(false, null);
} else {
  _showNoSpotsPopup(context);
}
        },
      ),
    ),
    Container(
      width: width * 0.5,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          padding: EdgeInsets.all(10),
          backgroundColor: kprimaryColor,
        ),
        child: const Text(
          'PAY NOW',
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        onPressed: () async {
            DateTime checkInDateTime = DateTime(
  _checkInDate!.year,
  _checkInDate!.month,
  _checkInDate!.day,
  _checkInTime.hour,
  _checkInTime.minute,
);
DateTime checkOutDateTime = DateTime(
  _checkOutDate!.year,
  _checkOutDate!.month,
  _checkOutDate!.day,
  _checkOutTime.hour,
  _checkOutTime.minute,
);

if (checkInDateTime.isBefore(DateTime.now())) {
  Fluttertoast.showToast(msg: "Check-in time must be in the future");
  return;
}
if (!checkOutDateTime.isAfter(checkInDateTime)) {
  Fluttertoast.showToast(msg: "Check-out must be after check-in");
  return;
}

 else {
            int availableSlots = await getAvailableSlots();
            if (availableSlots > 0) {
              openCheckout();
            } else {
              _showNoSpotsPopup(context);
            }
            
          }
        },
      ),
    ),
  ],
)
          ],
        ),
      ),
      ),
    );
  }
 
void _showNoSpotsPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Booking Not Possible"),
        content: Text("No spots are available at this time."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
Future<int> getAvailableSlots() async {
  try {
    CollectionReference reservations =
        FirebaseFirestore.instance.collection('reservations');

    String selectedCentre = widget.spot['name'];
    String selectedDate = formatter.format(_checkInDate!); // FIXED here

    DateTime checkInDateTime = DateTime(
      _checkInDate!.year,
      _checkInDate!.month,
      _checkInDate!.day,
      _checkInTime.hour,
      _checkInTime.minute,
    );
    DateTime checkOutDateTime = DateTime(
      _checkOutDate!.year,
      _checkOutDate!.month,
      _checkOutDate!.day,
      _checkOutTime.hour,
      _checkOutTime.minute,
    );

    QuerySnapshot querySnapshot = await reservations
        .where('centre', isEqualTo: selectedCentre)
        .where('date', isEqualTo: selectedDate)
        .get();

    int overlappingBookings = 0;

    for (var doc in querySnapshot.docs) {
      DateTime existingStart = DateTime.parse("${doc['checkinDate']} ${doc['checkin']}");
      DateTime existingEnd = DateTime.parse("${doc['checkoutDate']} ${doc['checkout']}");

      if (!(checkOutDateTime.isBefore(existingStart) || checkInDateTime.isAfter(existingEnd))) {
        overlappingBookings++;
      }
    }

    int totalSpots = widget.spot['totalSpots'];
    return max(0, totalSpots - overlappingBookings);
  } catch (e) {
    print("Error in getAvailableSlots: $e");
    return 0; // fallback
  }
}


int _timeStringToMinutes(dynamic time) {
  if (time is int) {
    return time; // If Firestore already stored as int
  } else if (time is String) {
    List<String> parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  throw Exception("Invalid time format: $time");
}



  void _initUserVehicles() {
     FirebaseFirestore.instance
        .collection('vehicles')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var vehicle in querySnapshot.docs) {
        _vehicles.add(vehicle['vehicleNumber']);
      }
      setState(() {
        _vehicles = [..._vehicles];
      });
    });
  }

  void openCheckout() async {
final durationInMinutes = DateTime(
  _checkOutDate!.year,
  _checkOutDate!.month,
  _checkOutDate!.day,
  _checkOutTime.hour,
  _checkOutTime.minute,
).difference(DateTime(
  _checkInDate!.year,
  _checkInDate!.month,
  _checkInDate!.day,
  _checkInTime.hour,
  _checkInTime.minute,
)).inMinutes;

int checkOutAmount = ((durationInMinutes / 60) * widget.spot['costPerHour']).ceil();
    print(checkOutAmount);
    var options = {
      'key': 'rzp_test_NJOOUWl7zCxApm',
      'amount': checkOutAmount * 100,
      'name': FirebaseAuth.instance.currentUser?.displayName,
      'description': 'Payment of Parking Spot',
      'prefill': {'email': FirebaseAuth.instance.currentUser?.email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: ${response.paymentId}", timeInSecForIosWeb: 4);
    addReservationToFirebase(true, response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName}", timeInSecForIosWeb: 4);
  }
Future<void> sendEmail() async {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  if (userEmail == null) {
    print("No user logged in.");
    return;
  }

  const String sendGridApiKey = "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"; // Replace with your API Key
  const String senderEmail = "velpurunavya@gmail.com";   // Must be a verified sender in SendGrid

  final Uri url = Uri.parse("https://api.sendgrid.com/v3/mail/send");

  final Map<String, dynamic> emailData = {
    "personalizations": [
      {
        "to": [
          {"email": userEmail}
        ],
        "subject": "Parking Spot Booking Confirmation"
      }
    ],
    "from": {"email": senderEmail, "name": "ParkSure"},
    "content": [
      {
        "type": "text/plain",
        "value": "Your parking spot at ${widget.spot['name']} has been successfully booked. Thanks for using ParkSure!"
      }
    ]
  };

  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $sendGridApiKey",
      "Content-Type": "application/json"
    },
    body: jsonEncode(emailData),
  );

  if (response.statusCode == 202) {
    print("Email sent successfully to $userEmail");
  } else {
    print("Failed to send email: ${response.body}");
  }
}
  void addReservationToFirebase(paymentDone, transactionID) {
    CollectionReference reservations =
    FirebaseFirestore.instance.collection('reservations');
    CollectionReference parkingCentres =
    FirebaseFirestore.instance.collection('parkingCentres');

    reservations
      .add({
        'centre': widget.spot['name'],
        'vehicleNumber': dropdownValue,
        'date': formatter.format(_date),
        'checkin':
        "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
        'checkout':
        "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
       'cost': '${((DateTime(
                  _checkOutDate!.year,
                  _checkOutDate!.month,
                  _checkOutDate!.day,
                  _checkOutTime.hour,
                  _checkOutTime.minute,
                ).difference(DateTime(
                  _checkInDate!.year,
                  _checkInDate!.month,
                  _checkInDate!.day,
                  _checkInTime.hour,
                  _checkInTime.minute,
                )).inMinutes / 60) * widget.spot['costPerHour']).ceil()}',
'paymentMethod': paymentDone ? 'Online' : 'On Arrival',
        'transactionID': transactionID,
        'uid': FirebaseAuth.instance.currentUser!.uid.toString(),
        'checkinDate': DateFormat('yyyy-MM-dd').format(_checkInDate!),
'checkoutDate': DateFormat('yyyy-MM-dd').format(_checkOutDate!),
      })
        .then((value) => {
      currentOccupiedSpots =
      widget.spot['occupiedSpots'],
      
      parkingCentres
          .doc('${widget.spot['id']}')
          .update({
        'occupiedSpots': ++currentOccupiedSpots
      }),
      

     sendEmail(),

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return BookingSuccessful(
              key: UniqueKey(),  // Add a unique key
              spot: widget.spot,
                data: {
                  'ticketID': value.id,
                  'vehicleNumber': dropdownValue,
                  'centre': widget.spot['name'],
                  'date': formatter.format(_date),
                  'transactionID': transactionID ?? '',
                  'checkinDate': DateFormat('yyyy-MM-dd').format(_checkInDate!),
'checkoutDate': DateFormat('yyyy-MM-dd').format(_checkOutDate!),
                  'checkin':
                  "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
                  'checkout':
                  "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
                  'cost': '${((DateTime(
            _checkOutDate!.year,
            _checkOutDate!.month,
            _checkOutDate!.day,
            _checkOutTime.hour,
            _checkOutTime.minute,
          ).difference(DateTime(
            _checkInDate!.year,
            _checkInDate!.month,
            _checkInDate!.day,
            _checkInTime.hour,
            _checkInTime.minute,
          )).inMinutes / 60) * widget.spot['costPerHour']).ceil()}',
 });
          },
        ),
      )
    // ignore: invalid_return_type_for_catch_error
    }).catchError((error) => print("Failed to do reservation: $error"));
  }
}

// void addReservationToFirebase(bool paymentDone, String? transactionID) {
//   CollectionReference reservations =
//       FirebaseFirestore.instance.collection('reservations');
//   CollectionReference parkingCentres =
//       FirebaseFirestore.instance.collection('parkingCentres');

//   String selectedCentre = widget.spot['id'];
//   String selectedDate = formatter.format(_date);
//   int newCheckInMinutes = _checkInTime.hour * 60 + _checkInTime.minute;
//   int newCheckOutMinutes = _checkOutTime.hour * 60 + _checkOutTime.minute;


//   reservations
//       .where('centre', isEqualTo: widget.spot['name'])
//       .where('date', isEqualTo: selectedDate)
//       .get()
//       .then((querySnapshot) {
//     int overlappingBookings = 0;

//     for (var doc in querySnapshot.docs) {
//       int existingCheckInMinutes = _timeStringToMinutes(doc['checkin']);
//       int existingCheckOutMinutes = _timeStringToMinutes(doc['checkout']);

//       // Check if the new booking overlaps with any existing booking
//       if (!(newCheckOutMinutes <= existingCheckInMinutes ||
//           newCheckInMinutes >= existingCheckOutMinutes)) {
//         overlappingBookings++;
//       }
//     }

//     int currentOccupiedSpots = widget.spot['occupiedSpots'];
//     int updatedOccupiedSpots = currentOccupiedSpots + 1 - overlappingBookings;

//     reservations.add({
//       'centre': widget.spot['name'],
//       'vehicleNumber': dropdownValue,
//       'date': selectedDate,
//       'checkin': _formatTime(_checkInTime),
//       'checkout': _formatTime(_checkOutTime),
//       'cost': _calculateCost(),
//       'paymentMethod': paymentDone ? 'Online' : 'On Arrival',
//       'transactionID': transactionID,
//       'uid': FirebaseAuth.instance.currentUser!.uid.toString(),
//     }).then((value) {
//       parkingCentres.doc(selectedCentre).update({
//         'occupiedSpots': updatedOccupiedSpots,
//       });
//        print("1");
//       sendEmail();
//       print("2");

//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (_) {
//             return BookingSuccessful(
//               key: UniqueKey(),
//               spot: widget.spot,
//               data: {
//                 'ticketID': value.id,
//                 'vehicleNumber': dropdownValue,
//                 'centre': widget.spot['name'],
//                 'date': selectedDate,
//                 'transactionID': transactionID ?? '',
//                 'checkin': _formatTime(_checkInTime),
//                 'checkout': _formatTime(_checkOutTime),
//                 'cost': _calculateCost(),
//               },
//             );
//           },
//         ),
//       );
//     // ignore: invalid_return_type_for_catch_error
//     }).catchError((error) => print("Failed to do reservation: $error"));
//   });
// }


// String _formatTime(TimeOfDay time) {
//   return "${time.hour < 10 ? '0${time.hour}' : time.hour}:${time.minute < 10 ? '0${time.minute}' : time.minute}";
// }

// String _calculateCost() {
//   return '${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * widget.spot['costPerHour']).round()}';
// }
