import 'package:flutter/material.dart';
import 'package:parking/constant.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Uncomment if using FirebaseAuth
// import 'package:parking/UserDashboard/dashboard.dart';
import 'landingScreen.dart'; // Uncomment for Landing Screen navigation

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // Delay for better UX

    // Navigate to LandingScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LandingScreen(), // Navigate to LandingScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/parkmeLogo.png", // Your app logo
              height: 100.0,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor), // Use kprimaryColor
            ),
            const SizedBox(height: 10),
            Text(
              "Loading...",
              style: TextStyle(color: kprimaryColor), // Use kprimaryColor
            ),
          ],
        ),
      ),
    );
  }
}
