import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/services/movie_service.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/movie_detail_page.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  final MovieService _movieService = MovieService(); // Instantiate MovieService

  UserProfilePage({super.key, required this.userId});

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();
      if (userDoc.exists) {
        var username = userDoc.data()?['username']?.toString() ?? '';
        var age = userDoc.data()?['age']?.toString() ?? '';
        var bio = userDoc.data()?['bio']?.toString() ?? '';
        var gender = userDoc.data()?['gender']?.toString() ?? '';
        var moviePreferences = userDoc.data()?['moviePreferences'] != null
            ? (userDoc.data()?['moviePreferences'] as List<dynamic>).join(', ')
            : '';
        var favMovies = userDoc.data()?['fav_movie'] != null
            ? List<int>.from(userDoc.data()?['fav_movie'] as List<dynamic>)
            : <int>[];
        var profilePic = await _getProfilePic(userId);
        return {
          'username': username,
          'age': age,
          'bio': bio,
          'gender': gender,
          'moviePreferences': moviePreferences,
          'favMovies': favMovies,
          'profilePic': profilePic,
        };
      } else {
        return {
          'username': 'Anonymous',
          'profilePic': null,
        };
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return {
        'username': 'Anonymous',
        'profilePic': null,
      };
    }
  }

  Future<Uint8List?> _getProfilePic(String userId) async {
    final storageref = FirebaseStorage.instance.ref().child('profile_pic/');
    final imageref = storageref.child("$userId.jpg");

    try {
      final img = await imageref.getData();
      return img;
    } catch (e) {
      print('Profile picture not found: $e');
      return null;
    }
  }

  Future<List<dynamic>> _fetchFavoriteMoviesDetails(List<int> movieIds) async {
    return await _movieService.fetchMoviesByIds(movieIds);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        } else {
          var userDetails = snapshot.data!;
          var profilePic = userDetails['profilePic'];
          var username = userDetails['username'];
          var age = userDetails['age'];
          var bio = userDetails['bio'];
          var gender = userDetails['gender'];
          var moviePreferences = userDetails['moviePreferences'];
          var favMovies = userDetails['favMovies'] as List<int>;

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(username),
                    background: profilePic != null
                        ? ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ).createShader(
                                  Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.darken,
                            child: Image.memory(
                              profilePic,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ).createShader(
                                  Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.darken,
                            child: Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInfoTile(context, 'Username', username),
                          _buildInfoTile(context, 'Age', age),
                          _buildInfoTile(context, 'Bio', bio),
                          _buildInfoTile(context, 'Gender', gender),
                          _buildInfoTile(
                              context, 'Movie Preferences', moviePreferences),
                          const SizedBox(height: 16),
                          const Text(
                            'Favorite Movies',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (favMovies.isEmpty)
                            const Text('No favorite movies'),
                          if (favMovies.isNotEmpty)
                            FutureBuilder<List<dynamic>>(
                              future: _fetchFavoriteMoviesDetails(favMovies),
                              builder: (context, movieSnapshot) {
                                if (movieSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (movieSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${movieSnapshot.error}',
                                          style: const TextStyle(
                                              color: Colors.white)));
                                } else {
                                  var movies = movieSnapshot.data!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: movies.length,
                                    itemBuilder: (context, index) {
                                      var movie = movies[index];
                                      String? posterPath = movie['poster_path'];
                                      String imageUrl = posterPath != null
                                          ? 'https://image.tmdb.org/t/p/w500$posterPath'
                                          : 'https://via.placeholder.com/500'; // A placeholder image URL
                                      return ListTile(
                                        leading: Image.network(imageUrl,
                                            width: 50, fit: BoxFit.cover),
                                        title: Text(
                                          movie['title'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'Release Date: ${movie['release_date']}'),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailPage(
                                                      movieId: movie['id']),
                                            ),
                                          );
                                        },
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
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value.isNotEmpty ? value : '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
