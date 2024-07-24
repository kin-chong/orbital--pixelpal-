import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/chat_overview.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/movie_detail_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/bottom_nav_bar.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'package:pixelpal/services/movie_service.dart';
import 'package:rxdart/rxdart.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BehaviorSubject<List<dynamic>> _searchResultsSubject = BehaviorSubject<List<dynamic>>();
  Future<List<dynamic>>? _recommendedMovies;
  Future<List<dynamic>>? _currentlyShowingMovies;
  Future<List<dynamic>>? _searchResults;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _recommendedMovies = _fetchRecommendedMovies();
    _currentlyShowingMovies = _movieService.fetchCurrentlyShowingMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchResultsSubject.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  Future<void> _refreshRecommendedMovies() async {
    setState(() {
      _recommendedMovies = _fetchRecommendedMovies();
    });
  }

  Future<List<dynamic>> _fetchRecommendedMovies() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        List<dynamic> interactedMovies = userDoc.get('interacted_movies') ?? [];
        List<int> movieIds = List<int>.from(interactedMovies);
        List<dynamic> recommendations = await _movieService.fetchRecommendedMovies(movieIds);
        // Ensure uniqueness
        return recommendations.toSet().toList();
      }
    }
    return [];
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      _searchResultsSubject.add([]);
    } else {
      var results = await _movieService.searchMovies(query);
      _searchResultsSubject.add(results);
    }
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
          title: _isSearchActive
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.tertiary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.tertiary),
                            onPressed: () {
                              _searchController.clear();
                              _searchResultsSubject.add([]);
                            },
                          )
                        : null,
                  ),
                )
              : Text(
                  'PixelPal',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: Theme.of(context).colorScheme.tertiary),
              onPressed: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                  if (!_isSearchActive) {
                    _searchController.clear();
                    _searchResultsSubject.add([]);
                  }
                });
              },
            ),
          ],
          bottom: _isSearchActive
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const TabBar(
                      indicatorColor: Colors.pinkAccent,
                      tabs: [
                        Tab(text: 'For You'),
                        Tab(text: 'Popular'),
                        Tab(text: 'Favorites'),
                      ],
                    ),
                  ),
                ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildRecommendedMoviesList(),
                _buildPopularMoviesList(),
                FavoritesTab(),
              ],
            ),
            _isSearchActive ? _buildSearchResultsOverlay() : Container(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            if (index != 0) {
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
                    NoAnimationPageRoute(page: ChatOverview()),
                  );
                case 4:
                  Navigator.pushReplacement(
                    context,
                    NoAnimationPageRoute(page: ProfileMenu()),
                  );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: StreamBuilder<List<dynamic>>(
          stream: _searchResultsSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var movie = snapshot.data![index];
                  String? posterPath = movie['poster_path'];
                  String imageUrl = posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500$posterPath'
                      : 'https://via.placeholder.com/500'; // A placeholder image URL

                  return ListTile(
                    leading: Image.network(imageUrl, width: 50),
                    title: Text(movie['title'],
                        style: TextStyle(
                            color: Colors.white)),
                    subtitle: Text('Release Date: ${movie['release_date']}',
                        style: TextStyle(
                            color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(
                            movieId: movie['id'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecommendedMoviesList() {
    return RefreshIndicator(
      onRefresh: _refreshRecommendedMovies,
      child: FutureBuilder<List<dynamic>>(
        future: _recommendedMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else {
            final movies = snapshot.data ?? [];
            final uniqueMovies = movies.toSet().toList();  // Ensure uniqueness
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: uniqueMovies.length,
              itemBuilder: (context, index) {
                var movie = uniqueMovies[index];
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
          final movies = snapshot.data ?? [];
          final uniqueMovies = movies.toSet().toList();  // Ensure uniqueness
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: uniqueMovies.length,
            itemBuilder: (context, index) {
              var movie = uniqueMovies[index];
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

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MovieService _movieService = MovieService();
  Future<List<int>>? _favoriteMovies;

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  void _loadFavoriteMovies() {
    setState(() {
      _favoriteMovies = _fetchFavoriteMovies();
    });
  }

  Future<List<int>> _fetchFavoriteMovies() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        List<dynamic> favMovies = userDoc.get('fav_movie') ?? [];
        return List<int>.from(favMovies);
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _favoriteMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else {
          List<int> favoriteMovieIds = snapshot.data ?? [];
          if (favoriteMovieIds.isEmpty) {
            return Center(
              child: Text(
                'No favorite movies',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            );
          }

          return FutureBuilder<List<dynamic>>(
            future: _movieService.fetchMoviesByIds(favoriteMovieIds),
            builder: (context, movieSnapshot) {
              if (movieSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (movieSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${movieSnapshot.error}',
                        style: const TextStyle(color: Colors.white)));
              } else {
                final movies = movieSnapshot.data ?? [];
                final uniqueMovies = movies.toSet().toList();  // Ensure uniqueness
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: uniqueMovies.length,
                  itemBuilder: (context, index) {
                    var movie = uniqueMovies[index];
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
                            ),
                          ),
                        ).then((value) {
                          if (value != null) {
                            _loadFavoriteMovies();
                          }
                        });
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
      },
    );
  }
}
