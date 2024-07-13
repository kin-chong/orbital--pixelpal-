import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../../services/movie_service.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  // final bool isFavorite;
  // final ValueChanged<bool> onFavoriteChanged;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    // required this.isFavorite,
    // required this.onFavoriteChanged,
  });

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieService _movieService = MovieService();
  Future<Map<String, dynamic>>? _movieDetails;
  YoutubePlayerController? _youtubePlayerController;
  bool _isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _movieDetails = _movieService.fetchMovieDetails(widget.movieId);
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        List<dynamic> favMovies = userDoc.get('fav_movie') ?? [];
        setState(() {
          _isFavorite = favMovies.contains(widget.movieId);
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentReference userDoc =
          _firestore.collection('Users').doc(currentUser.uid);

      try {
        if (_isFavorite) {
          await userDoc.update({
            'fav_movie': FieldValue.arrayUnion([widget.movieId])
          });
        } else {
          await userDoc.update({
            'fav_movie': FieldValue.arrayRemove([widget.movieId])
          });
        }
      } catch (e) {
        print('Error updating favorites: $e');
      }
    } else {
      print('No authenticated user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Movie Details',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.tertiary),
          onPressed: () => Navigator.of(context).pop(_isFavorite),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)));
          } else {
            final movie = snapshot.data!;
            final actors = movie['credits']['cast'];
            final trailers = movie['videos']['results'];
            final genres = movie['genres'];
            final platforms = [
              'Netflix',
              'Amazon Prime',
              'Disney+'
            ]; // Example platforms

            if (trailers.isNotEmpty) {
              final trailerKey = trailers[0]['key'];
              _youtubePlayerController = YoutubePlayerController(
                initialVideoId: trailerKey,
                flags: const YoutubePlayerFlags(
                  autoPlay: false,
                  mute: false,
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(
                              movie['poster_path'] != null
                                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                  : 'https://via.placeholder.com/500', // A placeholder image URL
                            ),
                            fit: BoxFit
                                .contain, // Ensure the full poster is displayed
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      movie['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Genres: ${genres.map((genre) => genre['name']).join(', ')}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Actors',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: actors.length,
                        itemBuilder: (context, index) {
                          final actor = actors[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${actor['profile_path']}'),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  actor['name'],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_youtubePlayerController != null) ...[
                      Text(
                        'Trailer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      YoutubePlayer(
                        controller: _youtubePlayerController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.brown,
                        onReady: () {
                          _youtubePlayerController!.addListener(() {});
                        },
                      ),
                    ] else
                      const Text(
                        'No trailer available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Available On',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: platforms
                          .map((platform) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  platform,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
