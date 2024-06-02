import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'services/movie_service.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieService _movieService = MovieService();
  Future<Map<String, dynamic>>? _movieDetails;
  YoutubePlayerController? _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _movieDetails = _movieService.fetchMovieDetails(widget.movieId);
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Movie Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow), // Make the back button yellow
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else {
            final movie = snapshot.data!;
            final actors = movie['credits']['cast'];
            final trailers = movie['videos']['results'];
            final genres = movie['genres'];
            final platforms = ['Netflix', 'Amazon Prime', 'Disney+']; // Example platforms

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
                      aspectRatio: 2 / 3, // Adjust the aspect ratio based on the poster's typical aspect ratio
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}'),
                            fit: BoxFit.contain, // Ensure the full poster is displayed
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      movie['title'],
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Genres: ${genres.map((genre) => genre['name']).join(', ')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Actors',
                      style: const TextStyle(
                        color: Colors.yellow,
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
                                  style: const TextStyle(
                                    color: Colors.white,
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
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      YoutubePlayer(
                        controller: _youtubePlayerController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.amber,
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
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: platforms
                          .map((platform) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  platform,
                                  style: const TextStyle(color: Colors.white70),
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
