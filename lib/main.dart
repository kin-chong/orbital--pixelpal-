import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'front_page.dart';
import 'forgot_password_page.dart';
import 'email_sent_page.dart';
import 'sign_up_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAOjo0ICshmA127L-EHlW2fItGzk4kQ8ww",
            appId: "1:374638859313:web:50144fd78cdd4fc5013110",
            messagingSenderId: "374638859313",
            projectId: "orbital-pixelpal"));
  }
  await Firebase.initializeApp();
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
