import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/presentation/widgets/form_container_widget.dart';

class SignUpPage extends StatelessWidget {
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
              SizedBox(height: 10),
              Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormContainerWidget(
                      hintText: "Username",
                      isPasswordField: false,
                    ),
                    SizedBox(height: 20),
                    FormContainerWidget(
                      hintText: "Email",
                      isPasswordField: false,
                    ),
                    SizedBox(height: 20),
                    FormContainerWidget(
                      hintText: "Password",
                      isPasswordField: true,
                    ),
                    SizedBox(height: 20),
                    FormContainerWidget(
                      hintText: "Confirm Password",
                      isPasswordField: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              /* ElevatedButton(
                onPressed: () {
                  // Add your sign-up logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: Text('Sign Up'),
              ), */
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
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
}
