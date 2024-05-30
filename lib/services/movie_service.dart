import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieService {
  final String _apiKey = '8945cfc7ae54a1979ef2afea7ef4f443';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['results'];
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<dynamic>> fetchPopularMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }
}
