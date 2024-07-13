import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:pixelpal/features/app/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:pixelpal/global/common/toast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpwdController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpwdController.dispose();
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
                'Sign Up',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormContainerWidget(
                      controller: _usernameController,
                      hintText: "Username",
                      isPasswordField: false,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    FormContainerWidget(
                      controller: _confirmpwdController,
                      hintText: "Confirm Password",
                      isPasswordField: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: 100,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Back to Login',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmpwdController.text;

    if (password == confirmPassword) {
      User? user = await _auth.signUpWithEmailandPassword(email, password);
      if (user != null) {
        showToast(message: "Account has been successfully created");

        // Save the new user flag and other user information in Firestore
        FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
          'username': username,
          'bio': 'Empty bio...',
          'isNew': true,  // Flag to indicate new user
        });

        // Navigate to the WelcomePage
        Navigator.pushReplacementNamed(context, "/welcome");
      } else {
        showToast(message: "Some error happened");
      }
    } else {
      showToast(message: "Passwords do not match!");
    }
  }
}
