import 'package:flutter/material.dart';
import 'login_page.dart';
import 'logout_page.dart';
import 'forgot_password_page.dart';
import 'email_sent_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbital App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/logout': (context) => LogoutPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/email_sent': (context) => EmailSentPage(),
      },
    );
  }
}
