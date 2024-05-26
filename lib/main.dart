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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAOjo0ICshmA127L-EHlW2fItGzk4kQ8ww",
            appId: "1:374638859313:web:50144fd78cdd4fc5013110",
            messagingSenderId: "374638859313",
            projectId: "orbital-pixelpal"));
  } else {
    await Firebase.initializeApp();
  }
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
        '/splash_screen': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/front': (context) => FrontPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/email_sent': (context) => EmailSentPage(),
        '/signup': (context) => SignUpPage(),
        '/upcoming_movies': (context) => UpcomingMoviesScreen(),
        // Define the /forum route if it's referenced somewhere in the app
        '/forum': (context) =>
            ForumPage(), // Assuming you have a ForumPage widget
      },
    );
  }
}

class UpcomingMoviesScreen extends StatefulWidget {
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
        title: Text('Upcoming Movies'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _movieService.fetchUpcomingMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var movie = snapshot.data![index];
                return ListTile(
                  leading: Image.network(
                      'https://image.tmdb.org/t/p/w92${movie['poster_path']}'),
                  title: Text(movie['title'],
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(movie['release_date'],
                      style: TextStyle(color: Colors.white70)),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Define the ForumPage widget if you reference it in routes
class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: Center(
        child: Text('Forum Page Content'),
      ),
    );
  }
}
