import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieService {
  final String _apiKey = '8945cfc7ae54a1979ef2afea7ef4f443';

  Future<List<dynamic>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/upcoming?api_key=$_apiKey&language=en-US&page=1'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<dynamic>> fetchCurrentlyShowingMovies() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$_apiKey&language=en-US&page=1'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load currently showing movies');
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=credits,videos'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<List<dynamic>> fetchMoviesByIds(List<int> movieIds) async {
    List<dynamic> movies = [];
    for (int id in movieIds) {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/$id?api_key=$_apiKey&language=en-US'));

      if (response.statusCode == 200) {
        movies.add(json.decode(response.body));
      } else {
        throw Exception('Failed to load movie with id $id');
      }
    }
    return movies;
  }
}
