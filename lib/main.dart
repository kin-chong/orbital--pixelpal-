import 'package:flutter/material.dart';
import 'login_page.dart';
import 'logout_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Logout App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/logout': (context) => LogoutPage(),
      },
    );
  }
}
