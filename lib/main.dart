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
import 'package:pixelpal/global/common/theme.dart';
import 'package:pixelpal/global/common/theme_provider.dart';
import 'package:provider/provider.dart';
//import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_page.dart'; // Add ScanPage if it's not already added
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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      initialRoute: isLoggedIn ? '/front' : '/login',
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
        '/scan': (context) => ScanPage(),
        '/createPost': (context) => const CreatePostPage(),
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
