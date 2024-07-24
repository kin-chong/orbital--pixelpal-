import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../services/movie_service.dart';
import 'movie_detail_page.dart';

class ActorDetailPage extends StatelessWidget {
  final int actorId;

  const ActorDetailPage({super.key, required this.actorId});

  Future<Map<String, dynamic>> fetchActorDetails(int actorId) async {
    final response = await MovieService().fetchActorDetails(actorId);
    return response;
  }

  Future<List<dynamic>> fetchActorMovies(int actorId) async {
    final response = await MovieService().fetchActorMovies(actorId);
    if (response != null) {
      response.sort((a, b) => b['release_date'].compareTo(a['release_date']));
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchActorDetails(actorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final actor = snapshot.data!;
            final moviesFuture = fetchActorMovies(actorId);
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      actor['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    background: Image.network(
                      'https://image.tmdb.org/t/p/w500${actor['profile_path']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Age: ${actor['birthday'] != null ? DateTime.now().year - DateTime.parse(actor['birthday']).year : 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Biography:',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    actor['biography'] ?? 'No biography available',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Movies',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<dynamic>>(
                            future: moviesFuture,
                            builder: (context, movieSnapshot) {
                              if (movieSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (movieSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${movieSnapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              } else {
                                final movies = movieSnapshot.data!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: movies.length,
                                  itemBuilder: (context, index) {
                                    final movie = movies[index];
                                    final posterUrl = movie['poster_path'] != null
                                        ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                        : 'https://via.placeholder.com/50x75.png?text=No+Image';
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      child: ListTile(
                                        title: Text(movie['title']),
                                        subtitle: Text(movie['release_date']),
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            posterUrl,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.network(
                                                'https://via.placeholder.com/50x75.png?text=No+Image',
                                                width: 50,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
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
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
