import 'package:flutter/material.dart';
import 'login_page.dart';
import 'front_page.dart';
import 'forgot_password_page.dart';
import 'email_sent_page.dart';
import 'sign_up_page.dart';

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
        '/front': (context) => FrontPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/email_sent': (context) => EmailSentPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}
