import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:parking/Booking/BookingSuccessful.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
class SpeechToBooking extends StatefulWidget {
  @override
  _SpeechToBookingState createState() => _SpeechToBookingState();
}

List<Map<String, dynamic>> _chatMessages = [];  // Holds chat history

class _SpeechToBookingState extends State<SpeechToBooking> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedVehicle = "";
  late DateTime _date ;
  TimeOfDay _checkInTime = TimeOfDay(hour: 0, minute: 0);
TimeOfDay _checkOutTime = TimeOfDay(hour: 0, minute: 0);
 late int currentOccupiedSpots;
  Map<String, dynamic> _selectedSpot = {};  // Store selected parking spot
int _startTime = 0;  // Store the start time (24-hour format)
int _endTime = 0;    // Store the end time (24-hour format)

  bool _showTypingDots = false;
  final Map<String, int> numberWords = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
    "ten": 10
  };

  List<Map<String, dynamic>> _latestNearbySpots = [];
  List<String> _vehicles = [];
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _response = "";
  String _conversationStage = "start";  // could be: start, choose_location, etc.

 void _addMessage(String text, bool isBot) {
  setState(() {
    _chatMessages.add({'text': text, 'isBot': isBot});
  });

  if (isBot) {
    _speak(text);
  }
}
Future<void> _speak(String text) async {
  await _flutterTts.setLanguage("en-US");
  await _flutterTts.setPitch(1.0);
  await _flutterTts.speak(text);
}


  bool _permissionGranted = false;
  
 final DateFormat formatter = DateFormat('dd-MM-yyyy');
  @override
  void initState() {
    _date = DateTime.now();
    _initUserVehicles();
    super.initState();
    _speech = stt.SpeechToText();
    _checkMicPermissionAndStartListening();
    _addMessage("Hi, welcome to speech-based booking.\nDo you want to continue?", true);
    
  }

  Future<void> _checkMicPermissionAndStartListening() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    setState(() {
      _permissionGranted = status.isGranted;
    });

    if (status.isGranted) {
      _startListening(); // Start listening automatically
    }
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
    print(_vehicles);
  }

  void _startListening() async {
    if (_speech == null) return;

    bool available = await _speech!.initialize(
      onStatus: (val) {
        if (val == "notListening") {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (val) => print('Speech error: $val'),
    );

    if (available) {
      setState(() => _isListening = true);

      _speech!.listen(
        onResult: (val) {
          if (val.hasConfidenceRating && val.confidence < 0.5) return;

          setState(() => _response = val.recognizedWords.toLowerCase().trim());
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: false,
        localeId: 'en_US',
        pauseFor: Duration(seconds: 2),
        listenFor: Duration(seconds: 6),
      );
    }
  }

  void _restartListening() {
    _speech?.stop().then((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _startListening();
      });
    });
  }

  Future<void> _getCurrentLocationAndShowNearby() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double userLat = position.latitude;
      final double userLng = position.longitude;

      // Fetch parking centers from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('parkingCenters')
          .get();

      List<Map<String, dynamic>> nearbySpots = [];

      for (var doc in snapshot.docs) {
        final spot = doc.data() as Map<String, dynamic>;
        final coords = await locationFromAddress(spot['address']);
        if (coords.isNotEmpty) {
          final double distance = Geolocator.distanceBetween(
            userLat,
            userLng,
            coords[0].latitude,
            coords[0].longitude,
          );
          nearbySpots.add({
            'id' : spot['id'],
            'name': spot['name'],
            'address': spot['address'],
            'totalSpots': spot['totalSpots'],
            'costPerHour': spot['costPerHour'],
            'occupiedSpots': spot['occupiedSpots'],
            'distance': distance,
          });
        }
      }

      nearbySpots.sort((a, b) => a['distance'].compareTo(b['distance']));

      int maxSpotsToShow = nearbySpots.length >= 3 ? 3 : nearbySpots.length;
      _latestNearbySpots = nearbySpots.take(maxSpotsToShow).toList();

      for (int i = 0; i < _latestNearbySpots.length; i++) {
        final spot = _latestNearbySpots[i];
        _addMessage("${i + 1}. ${spot['name']}\n📍 ${spot['address']}", true);
      }

      _addMessage("Would you like to reserve one of these? Say yes or no.", true);
      _conversationStage = "await_reserve_confirmation";
      _restartListening();

    } catch (e) {
      _addMessage("Failed to get your location or find nearby spots. Try again.", true);
    }
  }

  Future<int> getAvailableSlots(Map<String, dynamic> selectedSpot, TimeOfDay checkInTime , TimeOfDay checkOutTime) async {
    CollectionReference reservations =
        FirebaseFirestore.instance.collection('reservations');
String selectedDate = formatter.format(_date);
   int newCheckInMinutes = checkInTime.hour * 60 + checkInTime.minute;
  int newCheckOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

    QuerySnapshot querySnapshot = await reservations
        .where('centre', isEqualTo: selectedSpot['name'])
        .where('date', isEqualTo: selectedDate)
        .get();

    int overlappingBookings = 0;

    for (var doc in querySnapshot.docs) {
      int existingCheckInMinutes = _timeStringToMinutes(doc['checkin']);
      int existingCheckOutMinutes = _timeStringToMinutes(doc['checkout']);

      if (!(newCheckOutMinutes <= existingCheckInMinutes ||
          newCheckInMinutes >= existingCheckOutMinutes)) {
        overlappingBookings++;
      }
    }

    int totalSpots = selectedSpot['totalSpots'];
    int availableSpots = totalSpots - overlappingBookings;

    return max(0,availableSpots);
  }
void _checkAvailabilityAndProceed() async {
  int availableSeats = await getAvailableSlots(_selectedSpot,_checkInTime, _checkOutTime);

  if (availableSeats >= 1) {
    _addMessage("✅ Available seats: $availableSeats. Proceeding to vehicle selection.", true);
    // Proceed to ask for vehicle choice
    _conversationStage = "select_vehicle";
    _askForVehicleSelection(); // This should display the user's saved vehicles
  } else {
    _addMessage("❌ No available spots for the selected time. Please pick a different time.", true);
    _conversationStage = "ask_start_time"; // Go back to start time input
    _restartListening();
  }
}

  int _timeStringToMinutes(String time) {
    List<String> parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _askForStartTime() {
    _addMessage("Please say the start time in 24-hour format (e.g., ten fifteen or 10:15).", true);
    _restartListening();
  }

  // void _askForEndTime() {
  //   _addMessage("Please say the end time in 24-hour format (e.g., ten thirty or 10:30).", true);
  //   _conversationStage = "await_vehicle_selection";
  //   _restartListening();
  // }

  // Ask for vehicle selection
  void _askForVehicleSelection() {
    if (_vehicles.isEmpty) {
      _addMessage("You don't have any vehicles registered.", true);
      return;
    }

    _addMessage("You have the following vehicles registered:", true);

    for (int i = 0; i < _vehicles.length; i++) {
      _addMessage("${i + 1}. ${_vehicles[i]}", true);
    }

    _addMessage("Please choose a vehicle by saying the number (e.g., one, two, etc.).", true);
    _conversationStage = "await_vehicle_selection";
    _restartListening();
  }

  // Convert both number words and digits to an integer
int _parseNumber(String input) {
  input = input.trim().toLowerCase();

  // Remove "number" if present (e.g., "number one" -> "one")
  input = input.replaceAll(RegExp(r'\bnumber\b'), '').trim();

  // Check for direct number word mappings
  if (numberWords.containsKey(input)) {
    return numberWords[input]!;
  }

  // Extract digits from the input and try parsing
  final match = RegExp(r"\d+").firstMatch(input);
  print(match);
  if (match != null) {
    return int.tryParse(match.group(0)!) ?? -1;
  }

  return -1;  // Return -1 for invalid input
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
        "value": "Your parking spot at ${_selectedSpot['name']} has been successfully booked. Thanks for using ParkSure!"
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
 Future<void> addReservationToFirebase(paymentDone, transactionID) async {
  print("step 1");
//   final String spotId = _selectedSpot['id'].toString();  // Ensure the ID is a string
//   final docSnapshot = await FirebaseFirestore.instance.collection('spots').doc(spotId).get();
// final spotData = docSnapshot.data(); // Extract data as a map
print("1");
    CollectionReference reservations =
    FirebaseFirestore.instance.collection('reservations');
    CollectionReference parkingCentres =
    FirebaseFirestore.instance.collection('parkingCentres');
    double costPerHour = (_selectedSpot['costPerHour'] as num).toDouble();
print("step 2");
    reservations
      .add({
        'centre': _selectedSpot['name'],
        'vehicleNumber': _selectedVehicle,
        'date': formatter.format(_date),
        'checkin':
        "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
        'checkout':
        "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
        'cost':
        '${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * _selectedSpot['costPerHour']).round()}',
        'paymentMethod': paymentDone ? 'Online' : 'On Arrival',
        'transactionID': transactionID,
        'uid': FirebaseAuth.instance.currentUser!.uid.toString(),
        'checkinDate': formatter.format(_date),
'checkoutDate': formatter.format(_date),
      })
        .then((value) => {
      currentOccupiedSpots =
      _selectedSpot['occupiedSpots'],
      
      parkingCentres
          .doc('${_selectedSpot['id']}')
          .update({
        'occupiedSpots': ++currentOccupiedSpots
      }),
      print("3"),

     sendEmail(),
 print("4"),
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return BookingSuccessful(
              key: UniqueKey(),  // Add a unique key
              spot: _selectedSpot,
                data: {
                  'ticketID': value.id,
                  'vehicleNumber': _selectedVehicle,
                  'centre': _selectedSpot['name'],
                  'date': formatter.format(_date),
                  'transactionID': transactionID ?? '',
                  'checkin':
                  "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
                  'checkout':
                  "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
                 'cost':
                  '${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * _selectedSpot['costPerHour']).round()}'
               
                });
          },
        ),
      ),
      _addMessage("✅ Booking confirmed! Ticket ID: ${value.id}", true),
_speech?.stop(), // Optional: stop further listening

    // ignore: invalid_return_type_for_catch_error
    }).catchError((error) => print("Failed to do reservation: $error"));
  }


  void _handleResponse(String input) {
    input = input.toLowerCase().trim();

    if (_conversationStage == "start" && (input.contains("yes") || input.contains("no"))) {
      if (input.contains("yes")) {
        _addMessage("Would you like to find parking near your current location or another location?", true);
        _conversationStage = "choose_location";
        _restartListening();
      } else if (input.contains("no")) {
        _addMessage("Okay, exiting voice booking.", true);
        Future.delayed(Duration(seconds: 2), () {
          _speech?.stop();
          Navigator.pop(context);
        });
      }
    }

    else if (_conversationStage == "choose_location" && (input.contains("current") || input.contains("my location"))) {
      _addMessage("Finding parking spots near your current location...", true);
      _conversationStage = "showing_nearby";
      _getCurrentLocationAndShowNearby();
    }

    else if (_conversationStage == "await_reserve_confirmation") {
      if (input.contains("yes")) {
        _addMessage("Please say the number (1, 2, etc.) of the parking spot you'd like to reserve.", true);
        _conversationStage = "await_number_selection";
        _restartListening();
      } else if (input.contains("no")) {
        _addMessage("Okay, let's go back.", true);
        _conversationStage = "choose_location";
        _restartListening();
      }
    }

    else if (_conversationStage == "await_number_selection") {
       int choice = _parseNumber(input);
      // final match = RegExp(r"\d+").firstMatch(input);
      // if (match != null) {
      //   choice = int.tryParse(match.group(0)!);
      // }

       if (choice >= 1 && choice <= _latestNearbySpots.length) {
 final selected = _latestNearbySpots[choice - 1];
 _selectedSpot = selected;
  _addMessage("You selected ${selected['name']}. It costs ₹${selected['costPerHour']} per hour. Total spots are ${selected['totalSpots']}. Proceeding to booking...", true);

  // Proceed to start time input
  _conversationStage = "await_start_time";
  _askForStartTime();
} else {
  print("Invalid choice: $choice");
  _addMessage("Invalid selection. Please choose a valid number.", true);
}


    }

    else if (_conversationStage == "await_start_time") {
  final match = RegExp(r"(\d{1,2}):(\d{2})").firstMatch(input);
if (match != null) {
  int hour = int.parse(match.group(1)!); // Hour part
  int minute = int.parse(match.group(2)!); // Minute part

  _checkInTime = TimeOfDay(hour: hour, minute: minute); // Set the TimeOfDay

  _addMessage("Got it checkInTime is $_checkInTime $_date. Now say the end time (in 24-hour format).", true);
  _conversationStage = "await_end_time";
  _restartListening();
}else {
    _addMessage("Please say a valid start time like '14' for 2 PM.", true);
    _restartListening();
  }
}

else if (_conversationStage == "await_end_time") {
 final match = RegExp(r"(\d{1,2}):(\d{2})").firstMatch(input);
if (match != null) {
  int hour = int.parse(match.group(1)!); // Hour part
  int minute = int.parse(match.group(2)!); // Minute part

  _checkOutTime = TimeOfDay(hour: hour, minute: minute); // Set the TimeOfDay
_addMessage("Got it checkOutTime is $_checkOutTime $_date. Checking for Availability ..", true);
   _checkAvailabilityAndProceed();  // Call the availability check here
} else {
    _addMessage("Please say a valid end time like '16' for 4 PM.", true);
    _restartListening();
  }
}


    else if (_conversationStage == "await_vehicle_selection") {
      
      int choice = _parseNumber(input);

      if (choice >= 1 && choice <= _vehicles.length) {
        final selectedVehicle = _vehicles[choice - 1];
        _selectedVehicle = selectedVehicle;
        _addMessage("You selected the vehicle: $selectedVehicle. Confirming your booking...", true);
        addReservationToFirebase(false, null);
        // Proceed to booking confirmation logic
      } else {
        _addMessage("Please choose a valid vehicle number from 1 to ${_vehicles.length}.", true);
        _restartListening();
      }
    }
  }

  @override
  void dispose() {
    _speech?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Voice Assistant"),
        backgroundColor: Colors.blue,
      ),
      body: _permissionGranted
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages[index];
                          return Align(
                            alignment: message['isBot']
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: message['isBot']
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_showTypingDots)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text("...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _response.isNotEmpty ? _response : "Tap mic and speak...",
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: _response.isNotEmpty
                                ? () {
                                    _addMessage(_response, false);
                                    _handleResponse(_response);
                                    setState(() => _response = '');
                                  }
                                : null,
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _isListening
                                      ? Colors.black26
                                      : Colors.redAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: _isListening ? Colors.black : Colors.red,
                              ),
                              onPressed: _startListening,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Text(
                "Microphone permission is required.",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
    );
  }
}
