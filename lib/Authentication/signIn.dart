import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parking/Authentication/Adminpage.dart';
import 'package:parking/Authentication/OwnerPage.dart';
import 'package:parking/Authentication/signUp.dart';
import 'package:parking/constant.dart';
import 'package:parking/UserDashboard/dashboard.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'ResetPassword.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showPassword = false;
  User ? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kprimaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Image.asset("assets/images/parkmeLogo.png"),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: Text(
                      "Welcome Back",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                    SizedBox(
                      height: 6,
                    ),
                    Center(
                        child: Text(
                      "Please sign in to continue!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email ID",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: kprimaryColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(
                                () => _showPassword = !_showPassword);
                          },
                        ),
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: kprimaryColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPassword()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kprimaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          _signInWithEmailAndPassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kprimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "SIGN IN",
                          style: TextStyle(color: kBtnTextColor, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp()),
                              );
                            },
                            child: Text(
                              "SIGN UP",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kprimaryColor),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        // if possible add horizontal line around this
                        "or continue with",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Image.asset(
                              "assets/images/google.png",
                              width: 40,
                              height: 40,
                            ),
                            onTap: () {
                              signInWithGoogle().then((result) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Dashboard(
                                        user: _currentUser!,
                                      );
                                    },
                                  ),
                                );
                                                            });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  // void _signInWithEmailAndPassword() async {
  //   try {
  //     final User? user = (await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     ))
  //         .user;
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (_) {
  //           return Dashboard(
  //             user: user!,
  //           );
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //         msg: "Invalid Credentials",
  //         toastLength: Toast.LENGTH_LONG,
  //       );
  //   }
  // }
void _signInWithEmailAndPassword() async {
  try {
    final User? user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )).user;

    if (user != null) {
      if (user.email == "gfg882004@gmail.com") {
        // Navigate to Admin Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AdminPage()),
        );
      } else {
        // Check user role from Firestore
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (doc.exists && doc['role'] == 'owner') {
            // Navigate to Owner Page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => OwnerPage()),
            );
          } else {
            // Navigate to Customer Dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Dashboard(user: user)),
            );
          }
        });
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Invalid Credentials",
      toastLength: Toast.LENGTH_LONG,
    );
  }
}

  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

         if (googleSignInAccount == null) {
    // Handle the case where the user didn't sign in
    return 'Sign-in failed';
  }
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    _currentUser = user;
    return '$user';
  }
}
