import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            TextField(
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.yellow),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
              ),
              style: TextStyle(color: Colors.yellow),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.yellow),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
              ),
              style: TextStyle(color: Colors.yellow),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/logout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
