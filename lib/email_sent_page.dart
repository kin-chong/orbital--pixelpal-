import 'package:flutter/material.dart';

class EmailSentPage extends StatelessWidget {
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
                'images/logo.png', // Path to your logo image
                width: 500,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text(
                    'Email Sent!',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Please check your email for further instructions.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Container(
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: Text('Back to Login'),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
