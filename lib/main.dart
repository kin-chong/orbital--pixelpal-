import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/splash_screen/splash_screen.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/login_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forgot_password_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/email_sent_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/sign_up_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/create_post_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixelpal/global/common/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/movie_service.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/welcome_page.dart'; // Import WelcomePage
import 'package:google_generative_ai/google_generative_ai.dart'; // Import the Google Gemini API package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAOjo0ICshmA127L-EHlW2fItGzk4kQ8ww",
        appId: "1:374638859313:web:50144fd78cdd4fc5013110",
        messagingSenderId: "374638859313",
        projectId: "orbital-pixelpal",
      ),
    );
    //const apiKey = 'AIzaSyD7G9jtJ5e6BZOYIiyoCaQNWhhVAlV8d-U';
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyD7G9jtJ5e6BZOYIiyoCaQNWhhVAlV8d-U');
  } else {
    await Firebase.initializeApp();
  }

  // Hardcoded API key
 // const apiKey = 'AIzaSyD7G9jtJ5e6BZOYIiyoCaQNWhhVAlV8d-U';

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyD7G9jtJ5e6BZOYIiyoCaQNWhhVAlV8d-U');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<GenerativeModel>(create: (_) => model),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PixelPal',
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: isLoggedIn ? '/authWrapper' : '/login',
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/front': (context) => const FrontPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/email_sent': (context) => const EmailSentPage(),
        '/signup': (context) => const SignUpPage(),
        '/upcoming_movies': (context) => const UpcomingMoviesScreen(),
        '/forum': (context) => const ForumPage(),
        '/profile': (context) => ProfileMenu(),
        '/home': (context) => const FrontPage(),
        '/scan': (context) => const ScanPage(),
        '/createPost': (context) => const CreatePostPage(),
        '/authWrapper': (context) => const AuthWrapper(),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('Users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                if (userData['isNew'] == true) {
                  return const WelcomePage();
                } else {
                  return const FrontPage();
                }
              } else {
                return const WelcomePage();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class UpcomingMoviesScreen extends StatefulWidget {
  const UpcomingMoviesScreen({super.key});

  @override
  _UpcomingMoviesScreenState createState() => _UpcomingMoviesScreenState();
}

class _UpcomingMoviesScreenState extends State<UpcomingMoviesScreen> {
  final MovieService _movieService = MovieService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Upcoming Movies'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _movieService.fetchUpcomingMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var movie = snapshot.data![index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                  ),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    movie['release_date'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
