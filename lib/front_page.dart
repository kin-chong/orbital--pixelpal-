import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'services/movie_service.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();

  Future<List<dynamic>>? _upcomingMovies;
  Future<List<dynamic>>? _popularMovies;

  @override
  void initState() {
    super.initState();
    _upcomingMovies = _movieService.fetchUpcomingMovies();
    _popularMovies = _movieService.fetchPopularMovies();
  }

  Future<void> _refreshUpcomingMovies() async {
    setState(() {
      _upcomingMovies = _movieService.fetchUpcomingMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: const Text(
            'PixelPal',
            style: TextStyle(color: Colors.white),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              color: Colors.black,
              child: TabBar(
                indicatorColor: Colors.pinkAccent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Popular'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingMoviesList(),
            _buildPopularMoviesList(),
            Center(
                child: Text('Favorite Movies',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home),
              label: 'Home',
              tooltip: 'Home Page',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.qrcode),
              label: 'Scan',
              tooltip: 'Scan Ticket',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.comments),
              label: 'Forum',
              tooltip: 'Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.cog),
              label: 'Settings',
              tooltip: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user),
              label: 'Profile',
              tooltip: 'Profile',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/scan');
                break;
              case 2:
                Navigator.pushNamed(context, '/forum');
                break;
              case 3:
                Navigator.pushNamed(context, '/settings');
                break;
              case 4:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingMoviesList() {
    return RefreshIndicator(
      onRefresh: _refreshUpcomingMovies,
      child: FutureBuilder<List<dynamic>>(
        future: _upcomingMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var movie = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.grey[850],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          width: double.infinity,
                          height: 225,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['title'],
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Release Date: ${movie['release_date']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                movie['overview'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPopularMoviesList() {
    return FutureBuilder<List<dynamic>>(
      future: _popularMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              var movie = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.grey[850],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        width: double.infinity,
                        height: 225,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title'],
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Release Date: ${movie['release_date']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              movie['overview'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
