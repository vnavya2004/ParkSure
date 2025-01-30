import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/Authentication/signIn.dart';
// import 'package:parking/UserDashboard/dashboard.dart';
import 'package:parking/constant.dart';
import 'package:parking/net/firebase.dart';
// import 'package:parking/net/database.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showPassword = false;

  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSuccess = true;//remove true one later as i added now
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      height: 50,
                    ),
                    Center(
                      child: Image.asset("assets/images/parkmeLogo.png"),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: Text(
                      "Create Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                    SizedBox(
                      height: 6,
                    ),
                    Center(
                        child: Text(
                      "Please fill following details to get started!",
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
                      controller: _displayName,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                            this._showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(
                                () => this._showPassword = !this._showPassword);
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
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          _registerAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kprimaryColor, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: Size(double.infinity, 50), // Minimum width and height
                        ),
                        child: Text(
                          "SIGN UP",
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
                            "Already have an account? ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()),
                              );
                            },
                            child: Text(
                              "SIGN IN",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

//   void _registerAccount() async {
//     final User user = (await _auth.createUserWithEmailAndPassword(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//     ))
//         .user;

//     if (user != null) {
// //      if (!user.emailVerified) {
// //        await user.sendEmailVerification();
// //      }
// // 
//       await user.updateProfile(displayName: _displayName.text);
//       userSetup(_displayName.text);
//       final user1 = _auth.currentUser;
//       //create a new document for the user with uid
      
      
//     //   Navigator.of(context).pushReplacement(
//     //     MaterialPageRoute(
//     //       builder: (_) {
//     //         return Dashboard(
//     //           user: user1,
//     //         );
//     //       },
//     //     ),
//     //   );
//     // } else {
//     //   // todo: Notify the user that sign-up was not successful along with the error
//     //   _isSuccess = false;
//     // }
//     // Show a success message instead of navigating to the Dashboard
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Success"),
//           content: Text("You have successfully signed up!"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 // Close the dialog
//                 Navigator.of(context).pop();
//                 // Optionally navigate to the SignIn screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => SignIn()),
//                 );
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   } else {
//     // Handle the failure case
//     _isSuccess = false;
//     // Optionally show an error message
//   }
//   }

  void _registerAccount() async {
  try {
    final User? user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    ))
        .user;

    if (user != null) {
    //   if (!user.emailVerified) {
    //     await user.sendEmailVerification();
    //  }
      // Successfully created the user
      await user.updateProfile(displayName: _displayName.text);
      userSetup(_displayName.text);
      // final user1 = _auth.currentUser;
    //      Navigator.pushReplacement(WW
    // context,
    // MaterialPageRoute(
    //   builder: (context) => Dashboard(user: user1!), // Use the non-null assertion operator (!)
    //       ),
    //     );
     
      // Show a success message
         showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("You have successfully signed up!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                // Optionally navigate to the SignIn screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
    } else {
      // Handle the failure case
      setState(() {
        _isSuccess = false;
      });
      _showErrorDialog("Sign-up failed. Please try again.");
    }
  } catch (e) {
    // Handle exceptions
    _showErrorDialog("An error occurred: $e");
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
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

}


// import 'package:flutter/material.dart';
// import 'package:parking/constant.dart';

// class SignUp extends StatefulWidget {
//   const SignUp({super.key});

//   @override
//   _SignUpState createState() => _SignUpState();
// }

// class _SignUpState extends State<SignUp> {
//   bool _showPassword = false;
//   final TextEditingController _displayName = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kprimaryBgColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.only(left: 16, right: 16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     SizedBox(
//                       height: 50,
//                     ),
//                     Center(
//                       child: Image.asset("assets/images/parkmeLogo.png"),
//                     ),
//                     SizedBox(
//                       height: 50,
//                     ),
//                     Center(
//                         child: Text(
//                       "Create Account",
//                       style:
//                           TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     )),
//                     SizedBox(
//                       height: 6,
//                     ),
//                     Center(
//                         child: Text(
//                       "Please fill following details to get started!",
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     )),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 50,
//                 ),
//                 Column(
//                   children: <Widget>[
//                     TextField(
//                       controller: _displayName,
//                       decoration: InputDecoration(
//                         labelText: "Name",
//                         labelStyle: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade400,
//                             fontWeight: FontWeight.w600),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: kprimaryColor),
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     TextField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: "Email ID",
//                         labelStyle: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade400,
//                             fontWeight: FontWeight.w600),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: kprimaryColor),
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: !_showPassword,
//                       decoration: InputDecoration(
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _showPassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: Colors.grey.shade400,
//                           ),
//                           onPressed: () {
//                             setState(
//                                 () => _showPassword = !_showPassword);
//                           },
//                         ),
//                         labelText: "Password",
//                         labelStyle: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade400,
//                             fontWeight: FontWeight.w600),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                           borderSide: BorderSide(color: kprimaryColor),
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Replace with desired action or functionality
//                           print("Sign Up button pressed");
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kprimaryColor, // Button color
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                         child: Text(
//                           "SIGN UP",
//                           style:
//                               TextStyle(color: kBtnTextColor, fontSize: 18),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text(
//                             "Already have an account? ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               // Replace with desired action or navigate to sign in
//                               print("Navigate to Sign In");
//                             },
//                             child: Text(
//                               "SIGN IN",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: kprimaryColor),
//                             ),
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
