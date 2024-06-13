import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixelpal/features/app/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:pixelpal/global/common/toast.dart';

import '../../firebase_auth_implementation/firebase_auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                isLightTheme
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo.png',
                width: 500,
              ),
              const SizedBox(height: 10),
              Text(
                'Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 750, // Set the static width here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FormContainerWidget(
                      controller: _emailController,
                      hintText: "Email",
                      isPasswordField: false,
                    ),
                    const SizedBox(height: 20),
                    FormContainerWidget(
                      controller: _passwordController,
                      hintText: "Password",
                      isPasswordField: true,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _signIn,
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        _signInWithGoogle();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.google,
                                  color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "Sign in with Google",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No account?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
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

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      showToast(message: "Account has been successfully signed in");
      Navigator.pushNamed(context, "/front");
    } else {
      //showToast(message: "Some error happened");
    }
  }

  _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          '374638859313-tij5p6jbstktbm7ugt5ae89b75koqid1.apps.googleusercontent.com',
    );

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      //print(googleSignInAccount?.email);
      String? email = googleSignInAccount?.email;
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        await _firebaseAuth.signInWithCredential(credential);

        /* print(googleSignInAccount.photoUrl);
        print(googleSignInAccount.email); */

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .get();

        if (!userDoc.exists) {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(email)
              .set({'username': email, 'bio': 'Empty bio...'});
        }

        Navigator.pushNamed(context, "/front");
      }
    } catch (e) {
      showToast(message: "Some error occurred $e");
    }
  }
}
