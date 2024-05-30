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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/logo.png',
                width: 500,
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.yellow,
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
                    /* SizedBox(height: 20),
                    FormContainerWidget(
                      hintText: "Confirm Password",
                      isPasswordField: true,
                    ), */
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
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white),
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

    User? user = await _auth.signUpWithEmailandPassword(email, password);

    if (user != null) {
      showToast(message: "Account has been successfully created");
      Navigator.pushNamed(context, "/front");
    } else {
      //showToast(message: "Some error happened");
    }
  }
}
