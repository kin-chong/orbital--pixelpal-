import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/splash_screen/splash_screen.dart';
import 'features/app/user_auth/presentation/pages/login_page.dart';
import 'front_page.dart';
import 'forgot_password_page.dart';
import 'email_sent_page.dart';
import 'features/app/user_auth/presentation/pages/sign_up_page.dart';
import 'services/movie_service.dart';

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
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbital App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/login',
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/front': (context) => const FrontPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/email_sent': (context) => const EmailSentPage(),
        '/signup': (context) => const SignUpPage(),
        '/upcoming_movies': (context) => const UpcomingMoviesScreen(),
        '/forum': (context) => const ForumPage(), // Ensure this widget is defined
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
            return Center(child: Text('Error: ${snapshot.error}'));
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

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: const Center(
        child: Text('Forum Page Content'),
      ),
    );
  }
}