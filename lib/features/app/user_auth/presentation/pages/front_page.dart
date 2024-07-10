import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/movie_detail_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/bottom_nav_bar.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'package:pixelpal/services/movie_service.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();

  Future<List<dynamic>>? _upcomingMovies;
  Future<List<dynamic>>? _currentlyShowingMovies;
  Set<int> _favoriteMovieIds = {};

  @override
  void initState() {
    super.initState();
    _upcomingMovies = _movieService.fetchUpcomingMovies();
    _currentlyShowingMovies = _movieService.fetchCurrentlyShowingMovies();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          title: Text(
            'PixelPal',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                indicatorColor: Colors.pinkAccent,
                labelColor: Theme.of(context).colorScheme.tertiary,
                unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
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
            _buildFavoriteMoviesList(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            // Navigate to the appropriate page
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: FrontPage()),
                );
              case 1:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ScanPage()),
                );
              case 2:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ForumPage()),
                );
              case 3:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ProfileMenu()),
                );
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
                childAspectRatio: 1,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var movie = snapshot.data![index];
                String? posterPath = movie['poster_path'];
                String imageUrl = posterPath != null
                    ? 'https://image.tmdb.org/t/p/w500$posterPath'
                    : 'https://via.placeholder.com/500'; // A placeholder image URL

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: movie['id'],
                          isFavorite: _favoriteMovieIds.contains(movie['id']),
                          onFavoriteChanged: (isFavorite) {
                            setState(() {
                              if (isFavorite) {
                                _favoriteMovieIds.add(movie['id']);
                              } else {
                                _favoriteMovieIds.remove(movie['id']);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Release Date: ${movie['release_date']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
      future: _currentlyShowingMovies,
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
              childAspectRatio: 1,
            ),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              var movie = snapshot.data![index];
              String? posterPath = movie['poster_path'];
              String imageUrl = posterPath != null
                  ? 'https://image.tmdb.org/t/p/w500$posterPath'
                  : 'https://via.placeholder.com/500'; // A placeholder image URL

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        movieId: movie['id'],
                        isFavorite: _favoriteMovieIds.contains(movie['id']),
                        onFavoriteChanged: (isFavorite) {
                          setState(() {
                            if (isFavorite) {
                              _favoriteMovieIds.add(movie['id']);
                            } else {
                              _favoriteMovieIds.remove(movie['id']);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Release Date: ${movie['release_date']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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

  Widget _buildFavoriteMoviesList() {
    if (_favoriteMovieIds.isEmpty) {
      return Center(
        child: Text(
          'No favorite movies',
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _movieService.fetchMoviesByIds(_favoriteMovieIds.toList()),
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
              childAspectRatio: 1,
            ),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              var movie = snapshot.data![index];
              String? posterPath = movie['poster_path'];
              String imageUrl = posterPath != null
                  ? 'https://image.tmdb.org/t/p/w500$posterPath'
                  : 'https://via.placeholder.com/500'; // A placeholder image URL

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        movieId: movie['id'],
                        isFavorite: _favoriteMovieIds.contains(movie['id']),
                        onFavoriteChanged: (isFavorite) {
                          setState(() {
                            if (isFavorite) {
                              _favoriteMovieIds.add(movie['id']);
                            } else {
                              _favoriteMovieIds.remove(movie['id']);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Release Date: ${movie['release_date']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
