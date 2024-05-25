import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/presentation/widgets/form_container_widget.dart';

class LoginPage extends StatelessWidget {
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
                'Login',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: 750, // Set the static width here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FormContainerWidget(
                      hintText: "Username",
                      isPasswordField: false,
                    ),
                    SizedBox(height: 20),
                    FormContainerWidget(
                      hintText: "Password",
                      isPasswordField: true,
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/front');
                },
                child: Container(
                  width: 100,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/front');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: Text('Login'),
              ), */
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No account?',
                    style: TextStyle(
                      color: Colors.yellow,
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
                      style: TextStyle(color: Colors.white),
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
}
